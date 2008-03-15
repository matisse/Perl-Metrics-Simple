# $Header$
# $Revision$
# $Author$
# $Source$
# $Date$
###############################################################################

use strict;
use warnings;
use File::Spec qw();
use FindBin qw($Bin);
use lib "$Bin/lib";
use Perl::Metrics::Simple;
use Perl::Metrics::Simple::TestData;
use Readonly;
use Test::More tests => 17;

Readonly::Scalar my $TEST_DIRECTORY => "$Bin/test_files";

test_main_stats();
test_summary_stats();

exit;

sub set_up {
    my $counter = Perl::Metrics::Simple->new;
    return $counter;
}

sub test_main_stats {
    my $counter = set_up();
    my $main_subs_and_pod_test_file
        = File::Spec->join( $Bin, 'more_test_files', 'main_subs_and_pod.pl' );

    require $main_subs_and_pod_test_file;
    if ( !$main_subs_and_pod::EXPECTED_NON_SUB_LINES ) {
        Test::More::BAIL_OUT(
            "Could not get expected value from '$main_subs_and_pod_test_file'");
    }    
    my $analysis = $counter->analyze_files($main_subs_and_pod_test_file);
    Test::More::is(
        $analysis->main_stats()->{'lines'},
        $main_subs_and_pod::EXPECTED_NON_SUB_LINES,
        'main_stats() number of lines for file with subs and pod.'
    );

    my $test_file_for_end_token
        = File::Spec->join( $Bin, 'more_test_files', 'end_token.pl' );
    require $test_file_for_end_token;
    if ( !$end_token::EXPECTED_NON_SUB_LINES ) {
        Test::More::BAIL_OUT(
            "Could not get expected value from '$main_subs_and_pod_test_file'");
    }

    my $new_analysis = $counter->analyze_files($test_file_for_end_token);
    Test::More::is(
        $new_analysis->main_stats()->{'lines'},
        $end_token::EXPECTED_NON_SUB_LINES,
        'main_stats() finds correct number of lines.'
    );
    return 1;
}

sub test_summary_stats {
    my $counter    = set_up();
    my $analysis   = $counter->analyze_files($TEST_DIRECTORY);
    my $sub_length = $analysis->summary_stats->{sub_length};
    cmp_ok( $sub_length->{min},    '==', 1,   'minimum sub length.' );
    cmp_ok( $sub_length->{max},    '==', 9,   'maximum sub length.' );
    cmp_ok( $sub_length->{mean},   '==', 5.2, 'mean (average) sub length.' );
    cmp_ok( $sub_length->{median}, '==', 5,   'median sub length.' );
    cmp_ok( $sub_length->{standard_deviation},
        '==', 3.37, 'standard deviation of sub length.' );

    my $sub_complexity = $analysis->summary_stats->{sub_complexity};
    cmp_ok( $sub_complexity->{min}, '==', 1, 'minimum sub complexity.' );
    cmp_ok( $sub_complexity->{max}, '==', 6, 'maximum sub complexity.' );
    cmp_ok( $sub_complexity->{mean},
        '==', 2.6, 'mean (average) sub complexity.' );
    cmp_ok( $sub_complexity->{median}, '==', 1, 'median sub complexity.' );
    cmp_ok( $sub_complexity->{standard_deviation},
        '==', 2.06, 'standard deviation of sub complexity.' );

    my $main_complexity = $analysis->summary_stats->{main_complexity};
    cmp_ok( $main_complexity->{min}, '==', 1, 'minimum main complexity.' );
    cmp_ok( $main_complexity->{max}, '==', 3, 'maximum main complexity.' );
    cmp_ok( $main_complexity->{mean},
        '==', 1.75, 'mean (average) main complexity.' );
    cmp_ok( $main_complexity->{median}, '==', 1.5, 'median main complexity.' );
    cmp_ok( $main_complexity->{standard_deviation},
        '==', 0.83, 'standard deviation of main complexity.' );

    return 1;
}

