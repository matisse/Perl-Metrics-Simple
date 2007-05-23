# $Header: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/Build.PL,v 1.12 2007/05/23 15:40:48 matisse Exp $
# $Revision: 1.12 $
# $Author: matisse $
# $Source: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/Build.PL,v $
# $Date: 2007/05/23 15:40:48 $
###############################################################################
use strict;
use warnings;
use Module::Build;

# See perldoc Module::Build for details of how this works

Module::Build->new(
    module_name => 'Perl::Metrics::Simple',
    license     => 'perl',
    requires    => {
        'Readonly'            => 1.03,
        'PPI'                 => 1.113,
        'Statistics::Basic'   => 0.42,
        'Pod::Usage'          => 0,
    },
    build_requires => {
        'Module::Build' => 0.2612,
	'Test::Pod' => 1.00,
	'Test::Pod::Coverage' => 1.04,
    },
    script_files   => { 'bin/countperl' => 1, },
    add_to_cleanup => [ '*.tar.gz', 'Makefile', 'Makefile.old' ],
)->create_build_script;
