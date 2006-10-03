#!/usr/bin/perl
# $Header: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/old_examples/Attic/analyze.pl,v 1.9 2006/10/03 03:47:56 matisse Exp $
# $Revision: 1.9 $
# $Author: matisse $
# $Source: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/old_examples/Attic/analyze.pl,v $
# $Date: 2006/10/03 03:47:56 $
###############################################################################

use strict;
use warnings;
use Data::Dumper;
use Perl::Code::Analyze;
use Pod::Usage;
use Statistics::Basic::StdDev;
use Statistics::Basic::Mean;
use Statistics::Basic::Median;

pod2usage( -verbose => 1 ) if ( !@ARGV );
my $analzyer = Perl::Code::Analyze->new;

my $IMPROBABLY_LARGE_NUMBER = 999_999_999_999;

my $analysis = $analzyer->analyze_files(@ARGV);

my $file_count    = $analysis->file_count;
my $package_count = $analysis->package_count;
my $sub_count     = $analysis->sub_count;
my $lines         = $analysis->lines;
my $main_stats    = $analysis->main_stats;
my $file_stats    = $analysis->file_stats;

my %lines = ();
@lines{ 'min', 'max', 'counts' } =
  _get_min_max_values( $analysis->subs, 'lines' );
$lines{average} = sprintf '%.2f',
  Statistics::Basic::Mean->new( $lines{counts} )->query;

$lines{median} = sprintf '%.2f',
  Statistics::Basic::Median->new( $lines{counts} )->query;

my %complexity = ();
@complexity{ 'min', 'max', 'scores' } =
  _get_min_max_values( $analysis->subs, 'mccabe_complexity' );
$complexity{average} = sprintf '%.2f',
  Statistics::Basic::Mean->new( $complexity{scores} )->query;

$complexity{median} = sprintf '%.2f',
  Statistics::Basic::Median->new( $complexity{scores}, $sub_count )->query;
$complexity{standard_deviation} = sprintf '%.2f',
  Statistics::Basic::StdDev->new( $complexity{scores}, $sub_count )->query;

my %main_complexity = ();
$main_complexity{average} = sprintf '%.2f',
  $main_stats->{mccabe_complexity} / $file_count;
@main_complexity{ 'min', 'max', 'scores' } =
  _get_min_max_values( $analysis->subs, 'mccabe_complexity' );
$main_complexity{median} = sprintf '%.2f',
  Statistics::Basic::Median->new( $main_complexity{scores}, $file_count )->query;
$main_complexity{standard_deviation} = sprintf '%.2f',
  Statistics::Basic::StdDev->new( $main_complexity{scores}, $file_count )->query;

print <<"EOS";

Perl Files:      $file_count

Line Counts
-----------
lines:           $lines
packages:        $package_count
subs:            $sub_count
all main code:   $main_stats->{lines}

min. sub size:   $lines{min} lines
max. sub size:   $lines{max} lines
avg. sub size:   $lines{average} lines
median sub size: $lines{median}

McCabe Complexity
-----------------
min. main:    $main_complexity{min}
max. main:    $main_complexity{max}
median main:  $main_complexity{median}
average main: $main_complexity{average}

subs:
min:             $complexity{min}
max:             $complexity{max}
avg:             $complexity{average}
median:          $complexity{median}
std. deviation:  $complexity{standard_deviation}

EOS

my @sorted_subs = sort _by_complexity(), @{ $analysis->subs };
print join( "\t", 'complexity', 'sub', 'path', 'size' ), "\n";
foreach my $sub (@sorted_subs) {
    my %sub_hash = %{$sub};
    print join( "\t",
        @sub_hash{ 'mccabe_complexity', 'name', 'file_path', 'lines' } ),
      "\n";
}

exit;

sub _by_complexity {
    return $b->{mccabe_complexity} <=> $a->{mccabe_complexity};
}

sub _get_min_max_values {
    my $nodes    = shift;
    my $hash_key = shift;
    my @values   = ();
    my $min      = $IMPROBABLY_LARGE_NUMBER;
    my $max      = 0;
    foreach my $node ( @{$nodes} ) {
        my $value = $node->{$hash_key};
        $max = $value > $max ? $value : $max;
        $min = $value < $min ? $value : $min;
        push @values, $value;
    }

    return ( $min, $max, \@values );
}

__END__

=head1 NAME

analyze.pl -- example script to get perl metrics on Files.

=head1 SYNOPSIS

  analyze.pl file_or_directory [ file_or_dir2 ... ]

=cut


