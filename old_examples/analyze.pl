#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Perl::Code::Analyze;
use Statistics::Basic::StdDev;

my $analzyer = Perl::Code::Analyze->new;

my $IMPROBABLY_LARGE_NUMBER = 999_999_999_999;

my $analysis = $analzyer->analyze_files(@ARGV);

my $file_count    = $analysis->file_count;
my $package_count = $analysis->package_count;
my $sub_count     = $analysis->sub_count;
my $lines         = $analysis->lines;
my %lines = ();
@lines{'min', 'max','counts'} =
  _get_min_max_values( $analysis->subs, 'lines' );
$lines{average} =
    sprintf '%.2f', Statistics::Basic::Mean->new($lines{counts})->query;

my %complexity = ();
@complexity{'min', 'max', 'scores'} =
  _get_min_max_values( $analysis->subs, 'mccabe_complexity' );  
$complexity{average} =
   sprintf '%.2f', Statistics::Basic::Mean->new($complexity{scores})->query;
    
my $standard_deviation =
  sprintf '%.2f',
  Statistics::Basic::StdDev->new($complexity{scores},$sub_count)->query;


print <<"EOS";

Perl Files:      $file_count

Line Counts
-----------
lines:           $lines
packages:        $package_count
subs:            $sub_count
min. sub size:   $lines{min} lines
max. sub size:   $lines{max} lines
avg. sub size:   $lines{average} lines

McCabe Complexity
-----------------
min:             $complexity{min}
max:             $complexity{max}
avg:             $complexity{average}
std. deviation:  $standard_deviation

EOS

my @sorted_subs = sort _by_complexity(), @{ $analysis->subs };
print join("\t",'complexity', 'sub', 'path', 'size'), "\n";;
foreach my $sub ( @sorted_subs ) {
    my %sub_hash = %{ $sub };
    print join("\t", @sub_hash{'mccabe_complexity', 'name', 'file_path', 'lines'}), "\n";;
}

exit;

sub _by_complexity {
    return $b->{mccabe_complexity} <=> $a->{mccabe_complexity};
}

sub _get_min_max_values {
    my $nodes               = shift;
    my $hash_key            = shift;
    my @values              = ();
    my $min                 = $IMPROBABLY_LARGE_NUMBER;
    my $max                 = 0;
    foreach my $node ( @{$nodes} ) {
        my $value = $node->{$hash_key};
        $max = $value > $max ? $value : $max;
        $min = $value < $min ? $value : $min;
        push @values, $value;
    }

    return ( $min, $max, \@values );
}


