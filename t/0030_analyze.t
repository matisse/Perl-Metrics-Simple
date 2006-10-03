# $Header: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/t/0030_analyze.t,v 1.11 2006/10/03 03:53:08 matisse Exp $
# $Revision: 1.11 $
# $Author: matisse $
# $Source: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/t/0030_analyze.t,v $
# $Date: 2006/10/03 03:53:08 $
###############################################################################

use strict;
use warnings;
use English qw(-no_match_vars);
use Data::Dumper;
use FindBin qw($Bin);
use lib "$Bin/lib";
use Perl::Metrics::Simple::TestData;
use Readonly;
use Test::More tests => 17;

Readonly::Scalar my $TEST_DIRECTORY => "$Bin/test_files";
Readonly::Scalar my $EMPTY_STRING   => q{};
BEGIN { use_ok('Perl::Metrics::Simple'); }

test_analyze_one_file();
test_analyze_files();
test_analysis();

exit;

sub set_up {
    my $analyzer         = Perl::Metrics::Simple->new();
    my $test_data_object =
      Perl::Metrics::Simple::TestData->new( test_directory => $TEST_DIRECTORY );
    return ( $analyzer, $test_data_object );
}

sub test_analyze_one_file {
    my ( $analyzer, $test_data_object ) = set_up();
    my $test_data = $test_data_object->get_test_data;

    my $no_package_no_sub_expected_result =
      $test_data->{'no_packages_nor_subs'};
    my $analysis =
      $analyzer->analyze_one_file(
        $no_package_no_sub_expected_result->{'file_path'} );
    is_deeply(
        $analysis,
        $no_package_no_sub_expected_result,
        'analyze_one_file() with no packages nor subs.'
    );

    my $has_package_no_subs_expected_result =
      $test_data->{'package_no_subs.pl'};
    my $new_analysis =
      $analyzer->analyze_one_file(
        $has_package_no_subs_expected_result->{'file_path'} );
    is_deeply(
        $new_analysis,
        $has_package_no_subs_expected_result,
        'analyze_one_file() with one packages, no subs.'
    );

    my $has_subs_expected_result = $test_data->{'subs_no_package.pl'};
    my $has_subs_analysis        =
      $analyzer->analyze_one_file( $has_subs_expected_result->{'file_path'} );
    is_deeply( $has_subs_analysis, $has_subs_expected_result,
        'analyze_one_file() subs_no_package.pl' );

    my $has_subs_and_package_expected_result = $test_data->{'Module.pm'};
    my $subs_and_package_analysis            =
      $analyzer->analyze_one_file(
        $has_subs_and_package_expected_result->{'file_path'} );
    is_deeply(
        $subs_and_package_analysis,
        $has_subs_and_package_expected_result,
        'analyze_one_file() with packages and subs.'
    );
}

sub test_analyze_files {
    my ( $analyzer, $test_data_object ) = set_up();
    my $test_data            = $test_data_object->get_test_data;
    my $analysis_of_one_file =
      $analyzer->analyze_files( $test_data->{'Module.pm'}->{file_path} );
    isa_ok( $analysis_of_one_file, 'Perl::Metrics::Simple::Analysis' );
    my $expected_from_one_file = [ $test_data->{'Module.pm'}, ];
    is_deeply( $analysis_of_one_file->data, $expected_from_one_file,
        'analyze_files() when given a single file path.' );

    my $analysis = $analyzer->analyze_files($TEST_DIRECTORY);
    my $expected = [
        $test_data->{'Module.pm'},
        $test_data->{'no_packages_nor_subs'},
        $test_data->{'package_no_subs.pl'},
        $test_data->{'subs_no_package.pl'},
    ];
    is_deeply( $analysis->data, $expected,
        'analyze_files() given a directory path.' );
}

sub test_analysis {
    my ( $analyzer, $test_data_object ) = set_up();
    my $test_data = $test_data_object->get_test_data;

    my $analysis = $analyzer->analyze_files($TEST_DIRECTORY);

    my $expected_lines;
    map { $expected_lines += $test_data->{$_}->{lines} }
      keys %{$test_data};
    is( $analysis->lines, $expected_lines,
        'analysis->lines() returns correct number' );

    my @expected_files = (
        $test_data->{'Module.pm'}->{file_path},
        $test_data->{'no_packages_nor_subs'}->{file_path},
        $test_data->{'package_no_subs.pl'}->{file_path},
        $test_data->{'subs_no_package.pl'}->{file_path},
    );
    is_deeply( $analysis->files, \@expected_files,
        'analysis->files() contains expected files.' );
    is(
        $analysis->file_count,
        scalar @expected_files,
        'file_count() returns correct number.'
    );

    my @expected_packages = (
        'Perl::Metrics::Simple::Test::Module',
        'Perl::Metrics::Simple::Test::Module::InnerClass',
        'Hello::Dolly',
    );
    is_deeply( $analysis->packages, \@expected_packages,
        'analysis->packages() returns expected list.' );
    is(
        $analysis->package_count,
        scalar @expected_packages,
        'analysis->package_count returns correct number.'
    );

    my @expected_subs = ();
    foreach my $test_file ( sort keys %{$test_data} ) {
        my @subs = @{ $test_data->{$test_file}->{subs} };
        if ( scalar @subs ) {
            push @expected_subs, @subs;
        }
    }

    is_deeply( $analysis->subs, \@expected_subs,
        'analysis->subs() returns expected list.' );

    is(
        $analysis->sub_count,
        scalar @expected_subs,
        'analysis->subs_count returns correct number.'
    );

    my $expected_main_stats = $test_data_object->get_main_stats;
    is_deeply( $analysis->main_stats, $expected_main_stats,
        'analysis->main_stats returns expected data.' );

    my $expected_file_stats = $test_data_object->get_file_stats;
    is_deeply( $analysis->file_stats, $expected_file_stats,
        'analysis->file_stats returns expected data.' );
    return 1;
}

