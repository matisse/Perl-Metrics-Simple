use strict;
use warnings;
use English qw(-no_match_vars);
use FindBin qw($Bin);
use Readonly;
use Test::More tests => 5;

Readonly::Scalar my $TEST_DIRECTORY => "$Bin/test_files";
Readonly::Scalar my $EMPTY_STRING   => q{};
BEGIN { use_ok('Perl::Code::Analyze'); }

test_analyze_one_file();

exit;

sub set_up {
    my $analyzer = Perl::Code::Analyze->new();
}

sub test_analyze_one_file {
    my $analyzer            = set_up();
    my $no_packages_or_subs = "$TEST_DIRECTORY/a_sample_script";
    my $analysis            = $analyzer->analyze_one_file($no_packages_or_subs);
    my $no_packages_expected = {
        lines    => 8,
        subs     => [],
        packages => [],
    };
    is_deeply( $analysis, $no_packages_expected,
        'analyze_one_file() with no packages nor subs.' );

    my $has_package_no_subs = "$TEST_DIRECTORY/package_no_subs.pl";
    my $new_analysis        = $analyzer->analyze_one_file($has_package_no_subs);
    my $has_package_expected = {
        lines    => 12,
        subs     => [],
        packages => ['Hello::Dolly'],
    };
    is_deeply( $new_analysis, $has_package_expected,
        'analyze_one_file() with one packages, no subs.' );

    my $has_subs          = "$TEST_DIRECTORY/subs_no_package.pl";
    my $has_subs_analysis = $analyzer->analyze_one_file($has_subs);
    my $has_subs_expected = {
        lines => 11,
        subs  =>
          [ { name => 'foo', length => 1 }, { name => 'bar', length => 5 } ],
        packages => [],
    };
    is_deeply( $has_subs_analysis, $has_subs_expected,
        'analyze_one_file() with subs and no package.' );

    my $has_subs_and_package =
      "$TEST_DIRECTORY/Perl/Code/Analyze/Test/Module.pm";
    my $subs_and_package_analysis =
      $analyzer->analyze_one_file($has_subs_and_package);
    my $subs_and_package_expected = {
        lines => 26,
        subs  => [
            { name => 'new',       length => 5 },
            { name => 'args',      length => 4 },
            { name => 'say_hello', length => 4 },
        ],
        packages => [
            'Perl::Code::Analyze::Test::Module',
            'Perl::Code::Analyze::Test::Module::InnerClass'
        ],
    };
    is_deeply( $subs_and_package_analysis, $subs_and_package_expected,
        'analyze_one_file() with packages and subs.' );    
}
