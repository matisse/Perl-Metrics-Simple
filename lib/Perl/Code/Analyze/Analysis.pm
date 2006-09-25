# $Header: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/lib/Perl/Code/Analyze/Attic/Analysis.pm,v 1.3 2006/09/25 15:17:54 matisse Exp $
# $Revision: 1.3 $
# $Author: matisse $
# $Source: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/lib/Perl/Code/Analyze/Attic/Analysis.pm,v $
# $Date: 2006/09/25 15:17:54 $
###############################################################################

package Perl::Code::Analyze::Analysis;
use strict;
use warnings;

use Carp qw(confess);
use English qw(-no_match_vars);
use Readonly;

our $VERSION = '0.01';

my %AnalysisData = ();
my %Files        = ();
my %FileStats    = ();
my %Lines        = ();
my %Main         = ();
my %Packages     = ();
my %Subs         = ();

sub new {
    my ( $class, $analysis_data ) = @_;
    if (
        !(
                $analysis_data
            and ref $analysis_data
            and ref $analysis_data eq 'ARRAY'
        )
      )
    {
        confess 'Did not supply an arryref of analysis data.';
    }
    my $self = {};
    bless $self, ref $class || $class;
    $self->_init($analysis_data);    # Load object properties
    return $self;
}

sub files {
    my ($self) = @_;
    return $Files{$self};
}

sub data {
    my $self = shift;
    return $AnalysisData{$self};
}

sub file_count {
    my $self = shift;
    return scalar @{ $self->files };
}

sub lines {
    my $self = shift;
    return $Lines{$self};
}

sub packages {
    my ($self) = @_;
    return $Packages{$self};
}

sub package_count {
    my $self = shift;
    return scalar @{ $self->packages };
}

sub file_stats {
    my $self = shift;
    return $FileStats{$self};
}

sub main_stats {
    my $self = shift;
    return $Main{$self};
}

sub subs {
    my ($self) = @_;
    return $Subs{$self};
}

sub sub_count {
    my $self = shift;
    return scalar @{ $self->subs };
}

sub _init {
    my ( $self, $analysis_data ) = @_;
    $AnalysisData{$self} = $analysis_data;

    my @files    = ();
    my @packages = ();
    my $lines    = 0;
    my @subs;
    my @file_stats = ();
    my %main_stats = ( lines => 0, mccabe_complexity => 0 );
    foreach my $result ( @{ $self->data() } ) {
        $lines += $result->{lines};
        if ( exists $result->{main_stats} ) {
            my $main_for_this_file = $result->{main_stats};
            $main_stats{lines} += $main_for_this_file->{lines} || 0;
            $main_stats{mccabe_complexity} +=
              $main_for_this_file->{mccabe_complexity} || 0;
        }
        push @files, $result->{file_path};
        push @file_stats,
          { path => $result->{file_path}, main_stats => $result->{main_stats} };
        foreach my $package ( @{ $result->{packages} } ) {
            push @packages, $package;
        }
        foreach my $sub ( @{ $result->{subs} } ) {
            push @subs, $sub;
        }
    }
    $FileStats{$self} = \@file_stats;
    $Files{$self}     = \@files;
    $Main{$self}      = \%main_stats;
    $Packages{$self}  = \@packages;
    $Lines{$self}     = $lines;
    $Subs{$self}      = \@subs;
    return 1;
}
1;
__END__

#################### main pod documentation begin ###################
## Below is the stub of documentation for your module. 
## You better edit it!


=head1 NAME

Perl::Code::Analyze::Analysis - Contains anaylsis results.

=head1 SYNOPSIS

This is the class of objects returned by the I<analyze_files>
method of the B<Perl::Code::Analyze> class.

Normally you would not create objects of this class directly, instead you
get them by calling the I<analyze_files> method on a B<Perl::Code::Analyze>
object.

=head1 DESCRIPTION


=head1 USAGE

=head2 new

  $analysis = Perl::Code::Analyze::Analsys->new( $array_of_data )

Takes an arrayref of data and returns a new  Perl::Code::Analyze::Analysis
object.

=head2 data

The raw data for the analysis. This is the arryref you passed
as athe argument to new();

=head2 files

Arrayref of file paths, in the order they were encountered.

=head2 file_count

=head2 lines

Total lines in all files, including comments.

=head2 main_stats

Returns a hashref of data based the I<main> code in all files, that is,
on the code minus all named subroutines.

  {
    lines             => 723,
    mccabe_complexity => 45
  }

=head2 file_stats

Returns an arrayref of hashrefs, each entry is for one analyzed file,
in the order they were encountered. The I<main_stats> slot in the hashref
is for all the code in the file B<outside of> any named subroutines.

   [
      {
        path => '/path/to/file',
        main_stats => {
                        lines             => 23,
                        mccabe_complexity => 3,
                       },
        },
        ...
   ]

=head2 packages

Unique packages found in code.

=head2 packge_count

=head2 subs

Array ref containing names of all naed subroutines,
in the order encounted.

=head2 sub_count

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


