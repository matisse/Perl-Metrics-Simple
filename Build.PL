# $Header: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/Build.PL,v 1.14 2007/12/27 05:03:20 matisse Exp $
# $Revision: 1.14 $
# $Author: matisse $
# $Source: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/Build.PL,v $
# $Date: 2007/12/27 05:03:20 $
###############################################################################
use strict;
use warnings;
use Module::Build;


# See perldoc Module::Build for details of how this works

Module::Build->new(
    module_name => 'Perl::Metrics::Simple',
    license     => 'perl',
    requires    => {
        'Carp'                      => 0,
        'File::Find'                => 1.01,
        'IO::File'                  => 1.14,
        'Readonly'                  => 1.03,
        'PPI'                       => 1.113,
        'Statistics::Basic::StdDev' => 0,
        'Statistics::Basic::Mean'   => 0,
        'Statistics::Basic::Median' => 0,
        'Pod::Usage'                => 0,
    },
    recommends => {
        'Readonly::XS' => 1.02, # Speeds up Readonly scalars
    },
    build_requires => {
        'Module::Build'       => 0.2612,
        'Test::Pod'           => 1.00,
        'Test::Pod::Coverage' => 1.04,
    },
    script_files => { 'bin/countperl' => 1, },
    add_to_cleanup => [ '*.tar.gz', 'Makefile', 'Makefile.old' ],
)->create_build_script;
