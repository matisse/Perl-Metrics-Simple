# $Header: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/t/lib/Perl/Code/Analyze/Attic/TestData.pm,v 1.6 2006/09/25 15:17:54 matisse Exp $
# $Revision: 1.6 $
# $Author: matisse $
# $Source: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/t/lib/Perl/Code/Analyze/Attic/TestData.pm,v $
# $Date: 2006/09/25 15:17:54 $
###############################################################################

package Perl::Code::Analyze::TestData;
use strict;
use warnings;

use Carp qw(confess);
use English qw(-no_match_vars);
use Readonly;

our $VERSION = '0.01';

# Bad hack. Do this in the data instead!
our @ORDER_OF_FILES = qw(
  Module.pm
  no_packages_nor_subs
  package_no_subs.pl
  subs_no_package.pl
);

my %TestData = ();

sub new {
    my ( $class, %parameters ) = @_;
    my $self = {};
    bless $self, ref $class || $class;
    $TestData{$self} = $self->make_test_data( $parameters{test_directory} );
    return $self;
}

sub get_test_data {
    my $self = shift;
    return $TestData{$self};
}

sub get_main_stats {
    my $self       = shift;
    my $test_data  = $self->get_test_data;
    my $main_stats = {};

    foreach my $file_name (@ORDER_OF_FILES) {
        my $hash = $test_data->{$file_name};
        $main_stats->{lines}             += $hash->{main_stats}->{lines};
        $main_stats->{mccabe_complexity} +=
          $hash->{main_stats}->{mccabe_complexity};
    }
    return $main_stats;
}

sub get_file_stats {
    my $self       = shift;
    my $test_data  = $self->get_test_data;
    my @file_stats = ();
    foreach my $file_name (@ORDER_OF_FILES) {
        my $hash                    = $test_data->{$file_name};
        my $stats_hash_for_one_file = {
            path       => $hash->{file_path},
            main_stats => $hash->{main_stats},
        };
        push @file_stats, $stats_hash_for_one_file;
    }
    return \@file_stats;
}

sub make_test_data {
    my $self           = shift;
    my $test_directory = shift;
    if ( !-d $test_directory ) {
        confess "test_directory '$test_directory' not found! ";
    }
    my $test_data = bless {
        'no_packages_nor_subs' => {
            file_path  => "$test_directory/no_packages_nor_subs",
            lines      => 14,
            main_stats => { lines => 14, mccabe_complexity => 1, },
            subs       => [],
            packages   => [],
        },
        'package_no_subs.pl' => {
            file_path  => "$test_directory/package_no_subs.pl",
            lines      => 22,
            main_stats => {
                lines             => 22,
                mccabe_complexity => 2,
            },
            subs => [

            ],
            packages => ['Hello::Dolly'],
        },
        'subs_no_package.pl' => {
            file_path  => "$test_directory/subs_no_package.pl",
            lines      => 22,
            main_stats => { lines => 16, mccabe_complexity => 2, },
            subs       => [
                {
                    name              => 'foo',
                    lines             => 1,
                    mccabe_complexity => 1,
                    file_path         => "$test_directory/subs_no_package.pl",
                },
                {
                    name              => 'bar',
                    lines             => 5,
                    mccabe_complexity => 1,
                    file_path         => "$test_directory/subs_no_package.pl",
                }
            ],
            packages => [],
        },
        'Module.pm' => {
            file_path  => "$test_directory/Perl/Code/Analyze/Test/Module.pm",
            lines      => 43,
            main_stats => { lines => 22, mccabe_complexity => 1, },
            subs       => [
                {
                    name              => 'new',
                    lines             => 5,
                    mccabe_complexity => 1,
                    file_path         =>
                      "$test_directory/Perl/Code/Analyze/Test/Module.pm",
                },
                {
                    name              => 'foo',
                    lines             => 7,
                    mccabe_complexity => 2,
                    file_path         =>
                      "$test_directory/Perl/Code/Analyze/Test/Module.pm",
                },
                {
                    name              => 'say_hello',
                    lines             => 9,
                    mccabe_complexity => 4,
                    file_path         =>
                      "$test_directory/Perl/Code/Analyze/Test/Module.pm",
                },
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
1;
__END__



