#!/usr/bin/perl

use strict;
use warnings;
use Perl::Code::Analyze;
my $analzyer = Perl::Code::Analyze->new;

my $analysis = $analzyer->analyze_files(@ARGV);

my $file_count    = $analysis->file_count;
my $package_count = $analysis->package_count;
my $sub_count     = $analysis->sub_count;
my $lines         = $analysis->lines;
my $average_sub_size = sprintf '%.2f', _get_average($analysis->subs, 'lines');
print <<"EOS";

perl files:    $file_count
lines:         $lines
packages:      $package_count
subs:          $sub_count
avg. sub size: $average_sub_size lines

EOS

exit;

sub _get_average {
    my $nodes               = shift;
    my $property_to_average = shift;
    my $sum = 0;
    my $count = 0;
    foreach my $node ( @{ $nodes } ) {
        $count++;
        $sum += $node->{$property_to_average};
    }
    return $sum / $count;
}