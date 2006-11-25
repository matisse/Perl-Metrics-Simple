# $Header: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/lib/Perl/Metrics/Simple/Analysis/File.pm,v 1.3 2006/11/25 00:19:54 matisse Exp $
# $Revision: 1.3 $
# $Author: matisse $
# $Source: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/lib/Perl/Metrics/Simple/Analysis/File.pm,v $
# $Date: 2006/11/25 00:19:54 $
###############################################################################

package Perl::Metrics::Simple::Analysis::File;
use strict;
use warnings;

use Carp qw(cluck confess);
use Data::Dumper;
use English qw(-no_match_vars);
use Perl::Metrics::Simple::Analysis;
use PPI;
use Readonly;

our $VERSION = '0.001';

Readonly::Scalar my $ALL_NEWLINES_REGEX => qr/ ( \n ) /xm;
Readonly::Array our @LOGIC_OPERATORS    =>
  qw( ! && || ||= &&= or and xor not ? <<= >>= );
Readonly::Hash our %LOGIC_OPERATORS => hashify(@LOGIC_OPERATORS);

Readonly::Array our @LOGIC_KEYWORDS =>
  qw( for foreach goto if else elsif last next unless until while );
Readonly::Hash our %LOGIC_KEYWORDS => hashify(@LOGIC_KEYWORDS);

# Private instance variables:
my %Path       = ();
my %Main_Stats = ();
my %Subs       = ();
my %Packages   = ();
my %Lines      = ();

sub new {
    my ( $class, %parameters ) = @_;
    my $self = {};
    bless $self, ref $class || $class;
    $self->_init(%parameters);
    return $self;
}

sub _init {
    my ( $self, %parameters ) = @_;
    $Path{$self} = $parameters{path};

    my $path = $self->path;

    if ( !-r $path ) {
        confess "Path '$path' is missing or not readable!";
    }

    my $document = PPI::Document->new( $path, readonly => 1 );
    if ( !defined $document ) {
        cluck "Could not make a PPI document from '$path'";
        return;
    }
    $document->index_locations();
    my $packages = _get_packages($document);

    my @sub_analysis = ();
    my $sub_elements = $document->find('PPI::Statement::Sub');
    @sub_analysis = @{ $self->_iterate_over_subs( $sub_elements, $path ) };

    $Main_Stats{$self} =
      $self->analyze_main( $document, $sub_elements, \@sub_analysis );
    $Subs{$self}     = \@sub_analysis;
    $Packages{$self} = $packages;
    $Lines{$self}    = $self->get_node_length($document);

    return $self;
}

sub all_counts {
    my $self       = shift;
    my $stats_hash = {
        path       => $self->path,
        lines      => $self->lines,
        main_stats => $self->main_stats,
        subs       => $self->subs,
        packages   => $self->packages,
    };
    return $stats_hash;
}

sub analyze_main {
    my $self         = shift;
    my $document     = shift;
    my $sub_elements = shift;
    my $sub_analysis = shift;

    my $lines = $self->get_node_length($document);
    foreach my $sub ( @{$sub_analysis} ) {
        $lines -= $sub->{lines};
    }
    my $document_without_subs = $document->clone;
    $document_without_subs->prune('PPI::Statement::Sub');
    my $complexity = $self->measure_complexity($document_without_subs);
    my $results    = {
        lines             => $lines,
        mccabe_complexity => $complexity,
    };
    return $results;
}

sub get_node_length {
    my ( $self, $node ) = @_;
    my $string = $node->content;
    my @newlines = ( $string =~ /$ALL_NEWLINES_REGEX/mxg );
    return scalar @newlines + 1;
}

sub path {
    my ($self) = @_;
    return $Path{$self};
}

sub main_stats {
    my ($self) = @_;
    return $Main_Stats{$self};
}

sub subs {
    my ($self) = @_;
    return $Subs{$self};
}

sub packages {
    my ($self) = @_;
    return $Packages{$self};
}

sub lines {
    my ($self) = @_;
    return $Lines{$self};
}

sub measure_complexity {
    my $self  = shift;
    my $elem  = shift;
    my $count = 1;

    # Count up all the logic keywords, weed out hash keys
    my $keywords_ref = $elem->find('PPI::Token::Word');
    my @filtered = grep { !is_hash_key($_) } @{$keywords_ref};
    $count += grep { exists $LOGIC_KEYWORDS{$_} } @filtered;

    # Count up all the logic operators
    my $operators_ref = $elem->find('PPI::Token::Operator');
    if ($operators_ref) {
        $count += grep { exists $LOGIC_OPERATORS{$_} } @{$operators_ref};
    }
    return $count;
}

sub _get_packages {
    my $document = shift;

    my @unique_packages = ();
    my $found_packages  = $document->find('PPI::Statement::Package');

    return \@unique_packages
      if (
        !Perl::Metrics::Simple::Analysis::is_ref( $found_packages, 'ARRAY' ) );

    my %seen_packages = ();

    foreach my $package ( @{$found_packages} ) {
        $seen_packages{ $package->namespace() }++;
    }

    @unique_packages = sort keys %seen_packages;

    return \@unique_packages;
}

sub _iterate_over_subs {
    my $self       = shift;
    my $found_subs = shift;
    my $path       = shift;

    return []
      if ( !Perl::Metrics::Simple::Analysis::is_ref( $found_subs, 'ARRAY' ) );

    my @subs = ();

    foreach my $sub ( @{$found_subs} ) {
        my $sub_length = $self->get_node_length($sub);
        push @subs,
          {
            path              => $path,
            name              => $sub->name,
            lines             => $sub_length,
            mccabe_complexity => $self->measure_complexity($sub),
          };
    }
    return \@subs;
}

#-------------------------------------------------------------------------
# Copied from
# http://search.cpan.org/src/THALJEF/Perl-Critic-0.19/lib/Perl/Critic/Utils.pm
sub hashify {
    return map { $_ => 1 } @_;
}

#-------------------------------------------------------------------------
# Copied and somehwat simplified from
# http://search.cpan.org/src/THALJEF/Perl-Critic-0.19/lib/Perl/Critic/Utils.pm
sub is_hash_key {
    my $ppi_elem = shift;
    eval {
        my $parent      = $ppi_elem->parent();
        my $grandparent = $parent->parent();
        return 1 if $grandparent->isa('PPI::Structure::Subscript');
        my $sib = $ppi_elem->snext_sibling();
        return 1 if $sib->isa('PPI::Token::Operator') && $sib eq '=>';
    };
    return;
}

1;

__END__

=head1 NAME

Perl::Metrics::Simple::Analsys::File - Does Something Useful

=head1 SYNOPSIS

  use Perl::Metrics::Simple::Analsys::File;
  my $object = Perl::Metrics::Simple::Analsys::File->new(file => 'path/to/file');

=head1 CLASS METHODS

=head2 new

=head1 OBJECT METHODS

=head2 all_counts

Convenience method.
Takes no arguments and returns a hashref of all counts:
    {
        path       => $self->path,
        lines      => $self->lines,
        main_stats => $self->main_stats,
        subs       => $self->subs,
        packages   => $self->packages,
    }

=head1 AUTHOR

matisse

=cut

