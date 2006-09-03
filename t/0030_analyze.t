use strict;
use warnings;
use English qw(-no_match_vars);
use FindBin qw($Bin);
use Readonly;
use Test::More tests => 6;

Readonly::Scalar my $TEST_DIRECTORY => "$Bin/test_files";
Readonly::Scalar my $EMPTY_STRING   => q{};
BEGIN { use_ok('Perl::Code::Analyze'); }

test_analyze_one_file();

test_analyze_files();

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

    my $analysis = $analyzer->analyze_files($TEST_DIRECTORY);

    my $expected = [
        _get_test_data()->{'Module.pm'},
        _get_test_data()->{'no_packages_nor_subs'},
        _get_test_data()->{'package_no_subs.pl'},
        _get_test_data()->{'subs_no_package.pl'},
    ];
    is_deeply( $analysis, $expected, 'analyze_files()' );
}

sub _get_test_data {
    my $test_data = {
        'no_packages_nor_subs' => {
            file_path => "$TEST_DIRECTORY/no_packages_nor_subs",
            lines     => 8,
            subs      => [],
            packages  => [],
        },
        'package_no_subs.pl' => {
            file_path => "$TEST_DIRECTORY/package_no_subs.pl",
            lines     => 12,
            subs      => [],
            packages  => ['Hello::Dolly'],
        },
        'subs_no_package.pl' => {
            file_path => "$TEST_DIRECTORY/subs_no_package.pl",
            lines     => 11,
            subs      =>
              [ { name => 'foo', lines => 1 }, { name => 'bar', lines => 5 } ],
            packages => [],
        },
        'Module.pm' => {
            file_path => "$TEST_DIRECTORY/Perl/Code/Analyze/Test/Module.pm",
            lines     => 26,
            subs      => [
                { name => 'new',       lines => 5 },
                { name => 'args',      lines => 4 },
                { name => 'say_hello', lines => 4 },    
            ],
            packages => [
                'Perl::Code::Analyze::Test::Module',
                'Perl::Code::Analyze::Test::Module::InnerClass'
            ],
        },
    };
    return $test_data;
}
