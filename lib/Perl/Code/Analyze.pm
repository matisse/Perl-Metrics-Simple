# $Header: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/lib/Perl/Code/Attic/Analyze.pm,v 1.16 2006/09/25 15:17:54 matisse Exp $
# $Revision: 1.16 $
# $Author: matisse $
# $Source: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/lib/Perl/Code/Attic/Analyze.pm,v $
# $Date: 2006/09/25 15:17:54 $
###############################################################################

package Perl::Code::Analyze;
use strict;
use warnings;

use Carp qw(cluck confess);
use Data::Dumper;
use English qw(-no_match_vars);
use File::Basename qw(fileparse);
use File::Find qw(find);
use PPI;
use Perl::Code::Analyze::Analysis;
use Readonly;

our $VERSION = '0.012';

Readonly::Array my @PERL_FILE_SUFFIXES =>
  ( qr/ \.pl /xmi, qr/ \.pm /xmi, qr/ \.t /xmi );
Readonly::Scalar my $PERL_SHEBANG_REGEX => qr/ \A [#] ! .* perl /xm;
Readonly::Scalar my $DOT_FILE_REGEX     => qr/ \A [.] /xm;
Readonly::Scalar my $ALL_NEWLINES_REGEX => qr/ ( \n ) /xm;

Readonly::Array our @LOGIC_OPERATORS =>
  qw( && || ||= &&= or and xor ? <<= >>= );
Readonly::Hash our %LOGIC_OPERATORS => hashify(@LOGIC_OPERATORS);

Readonly::Array our @LOGIC_KEYWORDS =>
  qw( for foreach if else elsif unless until while );
Readonly::Hash our %LOGIC_KEYWORDS => hashify(@LOGIC_KEYWORDS);

sub new {
    my ( $class, %parameters ) = @_;

    my $self = {};
    bless $self, ref $class || $class;
    return $self;
}

sub analyze_files {
    my ( $self, @dirs_and_files ) = @_;
    my @results = ();
    foreach my $file ( @{ $self->find_files(@dirs_and_files) } ) {
        push @results, $self->analyze_one_file( $file, 'results_as_hash' );
    }
    my $analysis = Perl::Code::Analyze::Analysis->new( \@results );
    return $analysis;
}

sub analyze_one_file {
    my $self        = shift;
    my $path        = shift;
    my $return_type = shift || 'Perl::Code::Analyze::Analysis';
    if ( !-r $path ) {
        confess "Path '$path' is not readable!";
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
    if ($sub_elements) {
        @sub_analysis = @{ $self->_iterate_over_subs( $sub_elements, $path ) };
    }
    my $main = $self->analyze_main( $document, $sub_elements, \@sub_analysis );
    my $results_hash = {
        file_path  => $path,
        main_stats => $main,
        subs       => \@sub_analysis,
        packages   => $packages,
        lines      => $self->get_node_length($document),
    };

    return $results_hash;
}

sub analyze_main {
    my $self         = shift;
    my $document     = shift;
    my $sub_elements = shift || [];
    my $sub_analysis = shift || [];

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

sub find_files {
    my $self                  = shift;
    my @directories_and_files = @_;
    foreach my $path (@directories_and_files) {
        if ( !-r $path ) {
            confess "Path '$path' is not readable!";
        }
    }
    my @found = $self->list_perl_files(@directories_and_files);
    return \@found;
}

sub list_perl_files {
    my ( $self, @paths ) = @_;
    my @files;

    my $wanted = sub {
        if ( $self->is_perl_file($_) ) {
            push @files, $_;
        }
    };

    foreach my $path (@paths) {
        if ( -d $path ) {
            find( { wanted => $wanted, no_chdir => 1 }, $path );
        }
        elsif ( -f $path ) {
            if ( $self->is_perl_file($path) ) {
                push @files, $path;
            }
        }
    }
    return sort @files;
}

sub measure_complexity {
    my $self  = shift;
    my $elem  = shift;
    my $count = 1;

    # Count up all the logic keywords, weed out hash keys
    my $keywords_ref = $elem->find('PPI::Token::Word');
    if ($keywords_ref) {   # should always be true due to "sub" keyword, I think
        my @filtered = grep { !is_hash_key($_) } @{$keywords_ref};
        $count += grep { exists $LOGIC_KEYWORDS{$_} } @filtered;
    }

    # Count up all the logic operators
    my $operators_ref = $elem->find('PPI::Token::Operator');
    if ($operators_ref) {
        $count += grep { exists $LOGIC_OPERATORS{$_} } @{$operators_ref};
    }
    return $count;
}

sub is_perl_file {
    my ( $self, $path ) = @_;
    return if ( !-f $path );
    my ( $name, $path_part, $suffix ) = fileparse( $path, @PERL_FILE_SUFFIXES );
    return if $name =~ $DOT_FILE_REGEX;
    if ( length $suffix ) {
        return 1;
    }

    open my $fh, '<',
      $path || confess "Could not open '$path' for reading: $OS_ERROR";
    my $first_line = <$fh>;
    close $fh;
    $first_line ? return $first_line =~ $PERL_SHEBANG_REGEX : return;
}

#-------------------------------------------------------------------------
# Copied from
# http://search.cpan.org/src/THALJEF/Perl-Critic-0.19/lib/Perl/Critic/Utils.pm
sub hashify {
    return map { $_ => 1 } @_;
}

#-------------------------------------------------------------------------
# Copied from
# http://search.cpan.org/src/THALJEF/Perl-Critic-0.19/lib/Perl/Critic/Utils.pm
sub is_hash_key {
    my $elem = shift;
    return if !$elem;

    #Check curly-brace style: $hash{foo} = bar;
    my $parent = $elem->parent();
    return if !$parent;
    my $grandparent = $parent->parent();
    return   if !$grandparent;
    return 1 if $grandparent->isa('PPI::Structure::Subscript');

    #Check declarative style: %hash = (foo => bar);
    my $sib = $elem->snext_sibling();
    return if !$sib;
    return 1 if $sib->isa('PPI::Token::Operator') && $sib eq '=>';

    return;
}

sub _iterate_over_subs {
    my $self       = shift;
    my $found_subs = shift;
    my $path       = shift;

    my @subs = ();

    foreach my $sub ( @{$found_subs} ) {
        my $sub_length = $self->get_node_length($sub);
        push @subs,
          {
            file_path         => $path,
            name              => $sub->name,
            lines             => $sub_length,
            mccabe_complexity => $self->measure_complexity($sub),
          };
    }
    return \@subs;
}

sub _get_packages {
    my $document = shift;

    my $found_packages = $document->find('PPI::Statement::Package');
    my @packages       = ();
    my %seen_packages  = ();
    if ($found_packages) {
      PACKAGE:
        foreach my $package ( @{$found_packages} ) {
            $seen_packages{$package}++;
            if ( $seen_packages{$package} > 1 ) {
                next PACKAGE;
            }
            push @packages, $package->namespace();
        }
    }
    return \@packages;
}

1;

__END__

#################### main pod documentation begin ###################
## Below is the stub of documentation for your module. 
## You better edit it!


=head1 NAME

Perl::Code::Analyze - Count packages, subs, lines, etc. of many files.

=head1 SYNOPSIS

  use Perl::Code::Analyze;
  blah blah blah


=head1 DESCRIPTION

Stub documentation for this module was created by ExtUtils::ModuleMaker.
It looks like the author of the extension was negligent enough
to leave the stub unedited.

Blah blah blah.


=head1 USAGE

blah blah

=head1 PACKAGE PROPERTIES

Readonly values:

Used to measure mccabe_complexity, each occurance adds 1:

    Readonly::Array our @LOGIC_OPERATORS =>
      qw( && || ||= &&= or and xor ? <<= >>= );
    Readonly::Hash our %LOGIC_OPERATORS => hashify(@LOGIC_OPERATORS);
    
    Readonly::Array our @LOGIC_KEYWORDS =>
      qw( for foreach if else elsif unless until while );
    Readonly::Hash our %LOGIC_KEYWORDS => hashify(@LOGIC_KEYWORDS);

=head1 CLASS METHODS

=head2 new

Blah blah

=head1 OBJECT METHODS

=head2 analyze_files

=head2 analyze_one_file

=head2 find_files

=head2 get_node_length

=head2 list_perl_files

=head2 measure_complexity($PPI_node)

Attempts to measure the cyclomatic complexity of a chunk of code.

Takes a L<PPI::Node> and returns the total number of
logic keywords and logic operators. plus 1. See the C<PACKAGE PROPERTIES> section
for a list.

See also: http://en.wikipedia.org/wiki/Cyclomatic_complexity

The code for this method was copied from 
L<Perl::Critic::Policy::Subroutines::ProhibitExcessComplexity>

=head2 is_perl_file


=head1 BUGS



=head1 SUPPORT



=head1 AUTHOR

    Matisse Enzer
    CPAN ID: MATISSE
    Eigenstate Consulting, LLC
    matisse@eigenstate.net
    http://www.eigenstate.net/

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.


=head1 SEE ALSO

=over 4

=item L<PPI>

=item L<Perl::Critic>

=item http://en.wikipedia.org/wiki/Cyclomatic_complexity

=back

=cut

#################### main pod documentation end ###################


