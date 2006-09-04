# $Header: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/lib/Perl/Code/Attic/Analyze.pm,v 1.6 2006/09/04 01:40:36 matisse Exp $
# $Revision: 1.6 $
# $Author: matisse $
# $Source: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/lib/Perl/Code/Attic/Analyze.pm,v $
# $Date: 2006/09/04 01:40:36 $
###############################################################################

package Perl::Code::Analyze;
use strict;
use warnings;

use Carp qw(confess);
use English qw(-no_match_vars);
use File::Basename qw(fileparse);
use File::Find qw(find);
use PPI;
use Perl::Code::Analyze::Analysis;
use Readonly;

our $VERSION = '0.01';

Readonly::Array my @PERL_FILE_SUFFIXES =>
  ( qr/ \.pl /xmi, qr/ \.pm /xmi, qr/ \.t /xmi );
Readonly::Scalar my $PERL_SHEBANG_REGEX => qr/ \A [#] ! .* perl /xm;
Readonly::Scalar my $ALL_NEWLINES_REGEX => qr/ ( \n ) /xm;

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
        push @results, $self->analyze_one_file($file);
    }
    my $analysis = Perl::Code::Analyze::Analysis->new( \@results );
    return $analysis;
}

sub analyze_one_file {
    my ( $self, $path ) = @_;
    if ( !-r $path ) {
        confess "Path '$path' is not readable!";
    }
    my $document = PPI::Document->new( $path, readonly => 1 );
    $document->index_locations();
    my @subs       = ();
    my $found_subs = $document->find('PPI::Statement::Sub');
    if ($found_subs) {
        foreach my $sub ( @{$found_subs} ) {
            my $sub_length = $self->get_node_length($sub);
            push @subs,
              {
                name  => $sub->name,
                lines => $sub_length,
              };
        }
    }
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

    my $results_hash = {
        file_path => $path,
        subs      => \@subs,
        packages  => \@packages,
        lines     => $self->get_node_length($document),
    };
    return $results_hash;
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

sub is_perl_file {
    my ( $self, $path ) = @_;
    return if ( !-f $path );
    my ( $name, $path_part, $suffix ) = fileparse( $path, @PERL_FILE_SUFFIXES );
    if ( length $suffix ) {
        return 1;
    }

    open my $fh, '<',
      $path || confess "Could not open '$path' for reading: $OS_ERROR";
    my $first_line = <$fh>;
    close $fh;
    return 1 if $first_line =~ $PERL_SHEBANG_REGEX;
    return;
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



=head2 new

 Usage     : How to use this function/method
 Purpose   : What it does
 Returns   : What it returns
 Argument  : What it wants to know
 Throws    : Exceptions and other anomolies
 Comment   : This is a sample subroutine header.
           : It is polite to include more pod and fewer comments.

See Also   : 

=head2 analyze_files

=head2 analyze_one_file

=head2 find_files

=head2 get_node_length

=head2 list_perl_files

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

perl(1).

=cut

#################### main pod documentation end ###################


