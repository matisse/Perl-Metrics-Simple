# $Header: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/Build.PL,v 1.8 2006/11/24 04:23:43 matisse Exp $
# $Revision: 1.8 $
# $Author: matisse $
# $Source: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/Build.PL,v $
# $Date: 2006/11/24 04:23:43 $
###############################################################################

use Module::Build;

# See perldoc Module::Build for details of how this works

Module::Build->new(
    module_name => 'Perl::Metrics::Simple',
    license     => 'perl',
    requires    => {
        'Readonly'            => 1.03,
        'PPI'                 => 1.113,
        'Statistics::Basic'   => 0.42, 
    },
    build_requires => { 'Module::Build' => 0.2612, },
    script_files   => { 'bin/countperl' => 1, },
)->create_build_script;
