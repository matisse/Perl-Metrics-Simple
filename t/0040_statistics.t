# $Header$
# $Revision$
# $Author$
# $Source$
# $Date$
###############################################################################

use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib";
use Perl::Metrics::Simple;
use Perl::Metrics::Simple::TestData;
use Readonly;
use Test::More tests => 15;

Readonly::Scalar my $TEST_DIRECTORY => "$Bin/test_files";

test_summary_stats();

exit;

sub test_summary_stats {
    my $counter          = Perl::Metrics::Simple->new;
    my $analysis         = $counter->analyze_files($TEST_DIRECTORY);
    my $sub_length       = $analysis->summary_stats->{sub_length};
    cmp_ok( $sub_length->{min},    '==', 1,   'minimum sub length.' );
    cmp_ok( $sub_length->{max},    '==', 9,   'maximum sub length.' );
    cmp_ok( $sub_length->{mean},   '==', 5.4, 'mean (average) sub length.' );
    cmp_ok( $sub_length->{median}, '==', 5,   'median sub length.' );
    cmp_ok( $sub_length->{standard_deviation},
        '==', 3.2, 'standard deviation of sub length.' );
 
    my $sub_complexity      = $analysis->summary_stats->{sub_complexity};
    cmp_ok( $sub_complexity->{min},    '==', 1,   'minimum sub complexity.' );
    cmp_ok( $sub_complexity->{max},    '==', 6,   'maximum sub complexity.' );
    cmp_ok( $sub_complexity->{mean},   '==', 2.6, 'mean (average) sub complexity.' );
    cmp_ok( $sub_complexity->{median}, '==', 1,   'median sub complexity.' );
    cmp_ok( $sub_complexity->{standard_deviation},
        '==', 2.06, 'standard deviation of sub complexity.' );

    my $main_complexity      = $analysis->summary_stats->{main_complexity};
    cmp_ok( $main_complexity->{min},    '==', 1,   'minimum main complexity.' );
    cmp_ok( $main_complexity->{max},    '==', 3,   'maximum main complexity.' );
    cmp_ok( $main_complexity->{mean},   '==', 1.75, 'mean (average) main complexity.' );
    cmp_ok( $main_complexity->{median}, '==', 1.5,   'median main complexity.' );
    cmp_ok( $main_complexity->{standard_deviation},
        '==', 0.83, 'standard deviation of main complexity.' );
 
    return 1;
}

