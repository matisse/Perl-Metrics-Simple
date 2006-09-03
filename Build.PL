# $Header: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/Build.PL,v 1.2 2006/09/03 17:13:29 matisse Exp $
# $Revision: 1.2 $
# $Author: matisse $
# $Source: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/Build.PL,v $
# $Date: 2006/09/03 17:13:29 $
###############################################################################

use Module::Build;

# See perldoc Module::Build for details of how this works

Module::Build->new(
    module_name => 'Perl::Code::Analyze',
    license     => 'perl',
    requires    => {
        'Readonly' => 1.03,
        'PPI'      => 1.115,
    },
    build_requires => { 'Module::Build' => 0.28, },    
)->create_build_script;
