# $Header: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/lib/Perl/Metrics/Simple/Analysis.pm,v 1.4 2006/11/25 21:32:16 matisse Exp $
# $Revision: 1.4 $
# $Author: matisse $
# $Source: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/lib/Perl/Metrics/Simple/Analysis.pm,v $
# $Date: 2006/11/25 21:32:16 $
###############################################################################

package Perl::Metrics::Simple::Analysis;
use strict;
use warnings;

use Carp qw(confess);
use English qw(-no_match_vars);
use Readonly;
use Statistics::Basic::StdDev;
use Statistics::Basic::Mean;
use Statistics::Basic::Median;

our $VERSION = '0.02';

my %AnalysisData = ();
my %Files        = ();
my %FileStats    = ();
my %Lines        = ();
my %Main         = ();
my %Packages     = ();
my %Subs         = ();
my %SummaryStats = ();

sub new {
    my ( $class, $analysis_data ) = @_;
    if ( !is_ref( $analysis_data, 'ARRAY' ) ) {
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

sub summary_stats {
    my $self = shift;
    return $SummaryStats{$self};
}

sub subs {
    my ($self) = @_;
    return $Subs{$self};
}

sub sub_count {
    my $self = shift;
    return scalar @{ $self->subs };
}

sub _get_min_max_values {
    my $nodes    = shift;
    my $hash_key = shift;
    if ( !is_ref( $nodes, 'ARRAY' ) ) {
        confess("Didn't get an ARRAY ref, got '$nodes' instead");
    }
    my @sorted_values = sort numerically map $_->{$hash_key}, @{$nodes};
    my $min           = $sorted_values[0];
    my $max           = $sorted_values[-1];
    return ( $min, $max, \@sorted_values );
}

sub numerically {
    $a <=> $b;
}

sub _init {
    my ( $self, $analysis_data ) = @_;
    $AnalysisData{$self} = $analysis_data;

    my @all_files  = ();
    my @packages   = ();
    my $lines      = 0;
    my @subs       = ();
    my @file_stats = ();
    my %main_stats = ( lines => 0, mccabe_complexity => 0 );

    foreach my $file ( @{ $self->data() } ) {
        $lines                         += $file->lines;
        $main_stats{lines}             += $file->main_stats->{lines};
        $main_stats{mccabe_complexity} +=
          $file->main_stats->{mccabe_complexity};
        push @all_files, $file->path;
        push @file_stats,
          { path => $file->path, main_stats => $file->main_stats };
        push @packages, @{ $file->packages };
        push @subs,     @{ $file->subs };
    }

    $FileStats{$self}    = \@file_stats;
    $Files{$self}        = \@all_files;
    $Main{$self}         = \%main_stats;
    $Packages{$self}     = \@packages;
    $Lines{$self}        = $lines;
    $Subs{$self}         = \@subs;
    $SummaryStats{$self} = $self->_make_summary_stats;
    return 1;
}

sub _make_summary_stats {
    my $self          = shift;
    my $summary_stats = {
        sub_length      => $self->_summary_stats_sub_length,
        sub_complexity  => $self->_summary_stats_sub_complexity,
        main_complexity => $self->_summary_stats_main_complexity,
    };
    return $summary_stats;
}

sub _summary_stats_sub_length {
    my $self = shift;

    my %sub_length = ();

    @sub_length{ 'min', 'max', 'sorted_values' } =
      _get_min_max_values( $self->subs, 'lines' );

    @sub_length{ 'mean', 'median', 'standard_deviation' } =
       _get_mean_median_std_dev($sub_length{sorted_values});

    return \%sub_length;
}

sub _summary_stats_sub_complexity {
    my $self = shift;

    my %sub_complexity = ();

    @sub_complexity{ 'min', 'max', 'sorted_values' } =
      _get_min_max_values( $self->subs, 'mccabe_complexity' );

    @sub_complexity{ 'mean', 'median', 'standard_deviation' } =
       _get_mean_median_std_dev($sub_complexity{sorted_values});

    return \%sub_complexity;
}

sub _summary_stats_main_complexity {
    my $self = shift;

    my %main_complexity = ();

    my @main_stats = map $_->{main_stats}, @{ $self->file_stats };
    @main_complexity{ 'min', 'max', 'sorted_values' } =
      _get_min_max_values( \@main_stats, 'mccabe_complexity' );

    @main_complexity{ 'mean', 'median', 'standard_deviation' } =
       _get_mean_median_std_dev($main_complexity{sorted_values});

    return \%main_complexity;
}

sub is_ref {
    my $thing = shift;
    my $type  = shift;
    my $ref   = ref $thing;
    return if !$ref;
    return if ( $ref ne $type );
    return $ref;
}

sub _get_mean_median_std_dev {
    my $values = shift;
    my $count = scalar @{$values};
    if ( $count < 1 ) {
        return;
    }
    my $mean = sprintf '%.2f',
      Statistics::Basic::Mean->new( $values )->query;

    my $median = sprintf '%.2f',
      Statistics::Basic::Median->new( $values )->query;

    my $standard_deviation = sprintf '%.2f',
      Statistics::Basic::StdDev->new( $values,
        $count )->query;

    return ($mean,$median,$standard_deviation);
}

1;
__END__

#################### main pod documentation begin ###################

=head1 NAME

Perl::Metrics::Simple::Analysis - Contains anaylsis results.

=head1 SYNOPSIS

This is the class of objects returned by the I<analyze_files>
method of the B<Perl::Metrics::Simple> class.

Normally you would not create objects of this class directly, instead you
get them by calling the I<analyze_files> method on a B<Perl::Metrics::Simple>
object.

=head1 DESCRIPTION


=head1 USAGE

=head2 new

  $analysis = Perl::Metrics::Simple::Analsys->new( $array_of_data )

Takes an arrayref of data and returns a new  Perl::Metrics::Simple::Analysis
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

Array ref containing names of all named subroutines,
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


