# $Header: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/lib/Perl/Metrics/Simple.pm,v 1.11 2007/05/10 15:12:27 matisse Exp $
# $Revision: 1.11 $
# $Author: matisse $
# $Source: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/lib/Perl/Metrics/Simple.pm,v $
# $Date: 2007/05/10 15:12:27 $
###############################################################################

package Perl::Metrics::Simple;
use strict;
use warnings;

use Carp qw(cluck confess);
use Data::Dumper;
use English qw(-no_match_vars);
use File::Basename qw(fileparse);
use File::Find qw(find);
use PPI;
use Perl::Metrics::Simple::Analysis;
use Perl::Metrics::Simple::Analysis::File;
use Readonly;

our $VERSION = '0.032';

Readonly::Scalar our $PERL_FILE_SUFFIXES => qr{ \. (:? pl | pm | t ) }xmi;
Readonly::Scalar our $SKIP_LIST_REGEX    => qr{ \.svn | _darcs | CVS }xmi;
Readonly::Scalar my $PERL_SHEBANG_REGEX  => qr/ \A [#] ! .* perl /xm;
Readonly::Scalar my $DOT_FILE_REGEX      => qr/ \A [.] /xm;

sub new {
    my ($class) = @_;
    my $self = {};
    bless $self, ref $class || $class;
    return $self;
}

sub analyze_files {
    my ( $self, @dirs_and_files ) = @_;
    my @results = ();
    foreach my $file ( @{ $self->find_files(@dirs_and_files) } ) {
        my $file_analysis =
          Perl::Metrics::Simple::Analysis::File->new( path => $file );
        push @results, $file_analysis;
    }
    my $analysis = Perl::Metrics::Simple::Analysis->new( \@results );
    return $analysis;
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
        return if $self->should_be_skipped($File::Find::name);
        if ( $self->is_perl_file($File::Find::name) )
        {    ## no critic ProhibitPackageVars
            push @files, $File::Find::name;    ## no critic ProhibitPackageVars
        }
    };

    File::Find::find( { wanted => $wanted, no_chdir => 1 }, @paths );

    return sort @files;
}

sub should_be_skipped {
    my ( $self, $fullpath ) = @_;
    my ( $name, $path, $suffix ) = File::Basename::fileparse($fullpath);
    return $path =~ $SKIP_LIST_REGEX;
}

sub is_perl_file {
    my ( $self, $path ) = @_;
    return if ( !-f $path );
    my ( $name, $path_part, $suffix ) =
      File::Basename::fileparse( $path, $PERL_FILE_SUFFIXES );
    return if $name =~ $DOT_FILE_REGEX;
    if ( length $suffix ) {
        return 1;
    }
    return _has_perl_shebang($path);
}

sub _has_perl_shebang {
    my $path = shift;

    open my $fh, '<', $path;
    if ( !-r $fh ) {
        cluck "Could not open '$path' for reading: $OS_ERROR";
        return;
    }
    my $first_line = <$fh>;
    close $fh;
    return if ( !$first_line );
    return $first_line =~ $PERL_SHEBANG_REGEX;
}

1;

__END__

#################### main pod documentation begin ###################
## Below is the stub of documentation for your module. 
## You better edit it!


=head1 NAME

Perl::Metrics::Simple - Count packages, subs, lines, etc. of many files.

=head1 SYNOPSIS

  use Perl::Metrics::Simple;
  my $analzyer = Perl::Metrics::Simple->new;
  my $analysis = $analzyer->analyze_files(@ARGV);
  $file_count    = $analysis->file_count;
  $package_count = $analysis->package_count;
  $sub_count     = $analysis->sub_count;
  $lines         = $analysis->lines;
  $main_stats    = $analysis->main_stats;
  $file_stats    = $analysis->file_stats;

=head1 VERSION

This is VERSION 0.031

=head1 DESCRIPTION

Perl::Metrics::Simple is far simpler that Perl::Metrics.

Perl::Metrics::Simple provides just enough methods to run static analysis
of one or many Perl files and obtain a few metrics: packages, subroutines,
lines of code, and an approximation of cyclomatic (mccabe) complexity of
the subroutines and the "main" portion of the code.

Installs a a script called B<countperl>.

=head1 USAGE

See the F<countperl> script (included with this distribution)
for a simple example of usage.

=head1 CLASS METHODS

=head2 new

Takes no arguments and returns a new L<Perl::Metrics::Simple> object.

=head2 is_perl_file

Takes a path and returns true if the target is a Perl file.

=head1 OBJECT METHODS

=head2 analyze_files( @files_and_or_dirs )

Takes an array of files and or directory paths and returns
a L<Perl::Metrics::Simple::Analysis> object.

=head2 find_files

=head2 list_perl_files

Takes a list of one or more paths and returns an
alphabetically sorted list of only the perl files.
Uses I<is_perl_file> so may throw an exception if a file is unreadable.

=head2 is_perl_file($path)

Takes a path to a file and returns true if the file appears to be a Perl file,
otherwise returns false.

If the file name does not match any of @Perl::Metrics::Simple::PERL_FILE_SUFFIXES
then the file is opened for reading and the first line examined for a a Perl
'shebang' line. An exception is thrown if the file cannot be opened in this case.

=head2 should_be_skipped($path)

Returns true if the I<path> should be skipped when looking for Perl files.
Currently skips  F<.svn>, F<CVS>, and F<_darcs> directories.

=head1 BUGS AND LIMITATIONS

None reported yet :-)
See: http://rt.cpan.org/NoAuth/Bugs.html?Dist=Perl-Metrics-Simple

=head1 SUPPORT

Via CPAN:

=head2 Disussion Forum

http://www.cpanforum.com/dist/Perl-Metrics-Simple

=head2 Bug Reports

http://rt.cpan.org/NoAuth/Bugs.html?Dist=Perl-Metrics-Simple

=head1 AUTHOR

    Matisse Enzer
    CPAN ID: MATISSE
    Eigenstate Consulting, LLC
    matisse@eigenstate.net
    http://www.eigenstate.net/

=head1 LICENSE AND COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.


=head1 SEE ALSO

=over 4

=item The F<countperl> script included with this distribution.

=item L<PPI>

=item L<Perl::Critic>

=item L<Perl::Metrics>

=item http://en.wikipedia.org/wiki/Cyclomatic_complexity

=back

=cut

#################### main pod documentation end ###################


