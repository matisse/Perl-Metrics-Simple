# $Header: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/t/0030_analyze.t,v 1.5 2006/09/04 01:40:36 matisse Exp $
# $Revision: 1.5 $
# $Author: matisse $
# $Source: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/t/0030_analyze.t,v $
# $Date: 2006/09/04 01:40:36 $
###############################################################################

use strict;
use warnings;
use English qw(-no_match_vars);
use FindBin qw($Bin);
use Readonly;
use Test::More tests => 15;

Readonly::Scalar my $TEST_DIRECTORY => "$Bin/test_files";
Readonly::Scalar my $EMPTY_STRING   => q{};
BEGIN { use_ok('Perl::Code::Analyze'); }

test_analyze_one_file();
test_analyze_files();
test_analysis();

exit;

sub set_up {
    my $analyzer = Perl::Code::Analyze->new();
}

sub test_analyze_one_file {
    my $analyzer = set_up();

    my $no_package_no_sub_expected_result =
      _get_test_data()->{'package_no_subs.pl'};
    my $analysis =
      $analyzer->analyze_one_file(
        $no_package_no_sub_expected_result->{'file_path'} );
    is_deeply(
        $analysis,
        $no_package_no_sub_expected_result,
        'analyze_one_file() with no packages nor subs.'
    );

    my $has_package_no_subs_expected_result =
      _get_test_data()->{'package_no_subs.pl'};
    my $new_analysis =
      $analyzer->analyze_one_file(
        $has_package_no_subs_expected_result->{'file_path'} );
    is_deeply(
        $new_analysis,
        $has_package_no_subs_expected_result,
        'analyze_one_file() with one packages, no subs.'
    );

    my $has_subs_expected_result = _get_test_data()->{'subs_no_package.pl'};
    my $has_subs_analysis        =
      $analyzer->analyze_one_file( $has_subs_expected_result->{'file_path'} );
    is_deeply( $has_subs_analysis, $has_subs_expected_result,
        'analyze_one_file() with subs and no package.' );

    my $has_subs_and_package_expected_result = _get_test_data()->{'Module.pm'};
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
    my $analyzer = set_up();

    my $analysis_of_one_file =
      $analyzer->analyze_files( _get_test_data()->{'Module.pm'}->{file_path} );
    isa_ok( $analysis_of_one_file, 'Perl::Code::Analyze::Analysis' );
    my $expected_from_one_file = [ _get_test_data()->{'Module.pm'}, ];
    is_deeply( $analysis_of_one_file->data, $expected_from_one_file,
        'analyze_files() when given a single file path.' );

    my $analysis = $analyzer->analyze_files($TEST_DIRECTORY);
    my $expected = [
        _get_test_data()->{'Module.pm'},
        _get_test_data()->{'no_packages_nor_subs'},
        _get_test_data()->{'package_no_subs.pl'},
        _get_test_data()->{'subs_no_package.pl'},
    ];
    is_deeply( $analysis->data, $expected,
        'analyze_files() given a directory path.' );
}

sub test_analysis {
    my $analyzer = set_up();
    my $analysis = $analyzer->analyze_files($TEST_DIRECTORY);

    my $expected_lines;
    map { $expected_lines += _get_test_data()->{$_}->{lines} }
      keys %{ _get_test_data() };
    is(
        $analysis->lines, $expected_lines,    
        'analysis->lines() returns correct number'
    );

    my @expected_files = (
        _get_test_data()->{'Module.pm'}->{file_path},
        _get_test_data()->{'no_packages_nor_subs'}->{file_path},
        _get_test_data()->{'package_no_subs.pl'}->{file_path},
        _get_test_data()->{'subs_no_package.pl'}->{file_path},
    );
    is_deeply( $analysis->files, \@expected_files,
        'analysis->files() contains expected files.' );
    is(
        $analysis->file_count,
        scalar @expected_files,
        'file_count() returns correct number.'
    );

    my @expected_packages = (
        'Perl::Code::Analyze::Test::Module',
        'Perl::Code::Analyze::Test::Module::InnerClass',
        'Hello::Dolly',
    );
    is_deeply( $analysis->packages, \@expected_packages,
        'analysis->packages() returns expected list.' );
    is(
        $analysis->package_count,
        scalar @expected_packages,
        'analysis->package_count returns correct number.'
    );

    my @expected_subs = qw(
      new
      foo
      say_hello
      foo
      bar
    );
    is_deeply( $analysis->subs, \@expected_subs,
        'analysis->subs() returns expected list.' );
    is(
        $analysis->sub_count,
        scalar @expected_subs,
        'analysis->subs_count returns correct number.'
    );
    return 1;
}

sub _get_test_data {
    my $test_data = bless {
        'no_packages_nor_subs' => {
            file_path => "$TEST_DIRECTORY/no_packages_nor_subs",
            lines     => 14,
            subs      => [],
            packages  => [],
        },
        'package_no_subs.pl' => {
            file_path => "$TEST_DIRECTORY/package_no_subs.pl",
            lines     => 19,
            subs      => [],
            packages  => ['Hello::Dolly'],
        },
        'subs_no_package.pl' => {
            file_path => "$TEST_DIRECTORY/subs_no_package.pl",
            lines     => 22,
            subs      =>
              [ { name => 'foo', lines => 1 }, { name => 'bar', lines => 5 } ],
            packages => [],
        },
        'Module.pm' => {
            file_path => "$TEST_DIRECTORY/Perl/Code/Analyze/Test/Module.pm",
            lines     => 33,
            subs      => [
                { name => 'new',       lines => 5 },
                { name => 'foo',       lines => 4 },
                { name => 'say_hello', lines => 4 },
            ],
            packages => [
                'Perl::Code::Analyze::Test::Module',
                'Perl::Code::Analyze::Test::Module::InnerClass'
            ],
        },
      },
      'Perl::Code::Analyze::Analysis';
    return $test_data;
}
