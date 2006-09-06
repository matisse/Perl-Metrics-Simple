# $Header: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/Build.PL,v 1.4 2006/09/06 04:44:16 matisse Exp $
# $Revision: 1.4 $
# $Author: matisse $
# $Source: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/Build.PL,v $
# $Date: 2006/09/06 04:44:16 $
###############################################################################

use Module::Build;

# See perldoc Module::Build for details of how this works

Module::Build->new(
    module_name => 'Perl::Code::Analyze',
    license     => 'perl',
    requires    => {
        'Readonly'            => 1.03,
        'PPI'                 => 1.115,    
        'Perl::Critic::Utils' => 0.17,
    },
    build_requires => { 'Module::Build' => 0.2612, },
)->create_build_script;
