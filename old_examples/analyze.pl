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

print <<"EOS";

files:     $file_count
lines:     $lines
packages:  $package_count
subs:      $sub_count

EOS

exit;
