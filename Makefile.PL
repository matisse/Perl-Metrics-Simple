# $Revision: 1.1 $
# $Author: matisse $
# $Source: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/Makefile.PL,v $
# $Date: 2007/05/23 15:40:48 $
#
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab :
###############################################################################
use strict;
use warnings;
use 5.006001;
use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME          => 'Perl::Metrics::Simple',
    ABSTRACT_FROM => 'lib/Perl/Metrics/Simple.pm',
    AUTHOR        => 'J Matisse Enzer <matisse@cpan.org>',
    VERSION_FROM  => 'lib/Perl/Metrics/Simple.pm',           # finds $VERSION
    EXE_FILES     => ['bin/countperl'],
    PL_FILES      => {},
    PREREQ_PM     => {
        'Readonly'            => 1.03,
        'PPI'                 => 1.113,
        'Statistics::Basic'   => 0.42,
        'Pod::Usage'          => 0,
        'Test::Pod'           => 1.00,
        'Test::Pod::Coverage' => 1.04,
    },
);