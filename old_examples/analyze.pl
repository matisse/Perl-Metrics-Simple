#!/usr/bin/perl

use strict;
use warnings;
use Perl::Code::Analyze;
my $analzyer = Perl::Code::Analyze->new;

my $IMPROBABLY_LARGE_NUMBER = 999_999_999_999;

my $analysis = $analzyer->analyze_files(@ARGV);

my $file_count    = $analysis->file_count;
my $package_count = $analysis->package_count;
my $sub_count     = $analysis->sub_count;
my $lines         = $analysis->lines;
my ( $min_lines, $max_lines, $average_lines ) =
  _get_min_max_average( $analysis->subs, 'lines' );  
    
print <<"EOS";

perl files:    $file_count
lines:         $lines
packages:      $package_count
subs:          $sub_count
min. sub size: $min_lines lines
max. sub size: $max_lines lines
avg. sub size: $average_lines lines

EOS

exit;

sub _get_min_max_average {
    my $nodes               = shift;
    my $property_to_average = shift;
    my $sum                 = 0;
    my $count               = 0;
    my $min                 = $IMPROBABLY_LARGE_NUMBER;
    my $max                 = 0;
    foreach my $node ( @{$nodes} ) {
        my $value = $node->{$property_to_average};
        $max = $value > $max ? $value : $max;
        $min = $value < $min ? $value : $min;
        $count++;
        $sum += $value;
    }
    my $average = sprintf '%.2f', $sum / $count;

    return ( $min, $max, $average );
}
