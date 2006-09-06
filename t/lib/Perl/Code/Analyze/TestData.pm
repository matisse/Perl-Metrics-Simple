# $Header: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/t/lib/Perl/Code/Analyze/Attic/TestData.pm,v 1.3 2006/09/06 21:13:18 matisse Exp $
# $Revision: 1.3 $
# $Author: matisse $
# $Source: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/t/lib/Perl/Code/Analyze/Attic/TestData.pm,v $
# $Date: 2006/09/06 21:13:18 $
###############################################################################

package Perl::Code::Analyze::TestData;
use strict;
use warnings;

use Carp qw(confess);
use English qw(-no_match_vars);
use Readonly;

our $VERSION = '0.01';

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

sub make_test_data {
    my $self           = shift;
    my $test_directory = shift;
    if ( !-d $test_directory ) {
        confess "test_directory '$test_directory' not found! ";
    }
    my $test_data = bless {
        'no_packages_nor_subs' => {
            file_path => "$test_directory/no_packages_nor_subs",
            lines     => 14,
            subs      => [],
            packages  => [],
        },
        'package_no_subs.pl' => {
            file_path => "$test_directory/package_no_subs.pl",
            lines     => 19,
            subs      => [],
            packages  => ['Hello::Dolly'],
        },
        'subs_no_package.pl' => {
            file_path => "$test_directory/subs_no_package.pl",
            lines     => 22,
            subs      => [
                { name => 'foo', lines => 1, mccabe_complexity => 1,file_path => "$test_directory/subs_no_package.pl", },
                { name => 'bar', lines => 5, mccabe_complexity => 1,file_path => "$test_directory/subs_no_package.pl", }
            ],
            packages => [],
        },
        'Module.pm' => {
            file_path => "$test_directory/Perl/Code/Analyze/Test/Module.pm",
            lines     => 40,
            subs      => [
                { name => 'new',       lines => 5, mccabe_complexity => 1,file_path => "$test_directory/Perl/Code/Analyze/Test/Module.pm", },
                { name => 'foo',       lines => 4, mccabe_complexity => 1,file_path => "$test_directory/Perl/Code/Analyze/Test/Module.pm", },
                { name => 'say_hello', lines => 9, mccabe_complexity => 4,file_path => "$test_directory/Perl/Code/Analyze/Test/Module.pm", }
                ,    
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



