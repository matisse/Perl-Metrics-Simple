# $Header: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/Build.PL,v 1.7 2006/11/23 22:25:48 matisse Exp $
# $Revision: 1.7 $
# $Author: matisse $
# $Source: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/Build.PL,v $
# $Date: 2006/11/23 22:25:48 $
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
)->create_build_script;
