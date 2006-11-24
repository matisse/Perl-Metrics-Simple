# $Header: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/lib/Perl/Metrics/Simple.pm,v 1.4 2006/11/24 04:23:43 matisse Exp $
# $Revision: 1.4 $
# $Author: matisse $
# $Source: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/lib/Perl/Metrics/Simple.pm,v $
# $Date: 2006/11/24 04:23:43 $
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

our $VERSION = '0.02';

Readonly::Scalar our $PERL_FILE_SUFFIXES => qr{ \. (:? pl | pm | t ) }xmi;
Readonly::Scalar my $PERL_SHEBANG_REGEX  => qr/ \A [#] ! .* perl /xm;
Readonly::Scalar my $DOT_FILE_REGEX      => qr/ \A [.] /xm;

sub new {
    my ( $class) = @_;
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
        if ( $self->is_perl_file($_) ) {
            push @files, $_;
        }
    };

    File::Find::find( { wanted => $wanted, no_chdir => 1 }, @paths );

    return sort @files;
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

    open my $fh, '<',
      $path || confess "Could not open '$path' for reading: $OS_ERROR";
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

=head1 DESCRIPTION

Perl::Metrics::Simple is far simpler that Perl::Metrics.

Perl::Metrics::Simple provides just enough methods to run static analysis
of one or many Perl files and obtain a few metrics: packages, subroutines,
lines of code, and cyclomatic (mccabe) complexity of the subroutines and
the "main" portion of the code.

Installs a a script called B<countperl>.

=head1 USAGE

TODO: Fill in.


=head1 PACKAGE PROPERTIES

Readonly values:

Used to measure mccabe_complexity, each occurance adds 1:

    Readonly::Array our @LOGIC_OPERATORS =>
      qw( && || ||= &&= or and xor ? <<= >>= );
    Readonly::Hash our %LOGIC_OPERATORS => hashify(@LOGIC_OPERATORS);
    
    Readonly::Array our @LOGIC_KEYWORDS =>
      qw( for foreach goto if else elsif last next unless until while );
    Readonly::Hash our %LOGIC_KEYWORDS => hashify(@LOGIC_KEYWORDS);

=head1 CLASS METHODS

=head2 new

Blah blah

=head1 OBJECT METHODS

=head2 analyze_files( @files_and_or_dirs )

Takes an array of files and or directory paths and returns
a L<Perl::Metrics::Simple::Analysis> object.

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

=head2 is_perl_file($path)

Takes a path to a file and returns true if the file appears to be a Perl file,
otherwise returns false.

If the file name does not match any of @Perl::Metrics::Simple::PERL_FILE_SUFFIXES
then the file is opened for reading and the first line examined for a a Perl
'shebang' line. An exception is thrown if the file cannot be opened in this case.

=head1 BUGS

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

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.


=head1 SEE ALSO

=over 4

=item L<PPI>

=item L<Perl::Critic>

=item L<Perl::Metrics>

=item http://en.wikipedia.org/wiki/Cyclomatic_complexity

=back

=cut

#################### main pod documentation end ###################


