# -*- perl -*-
# $Header: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/t/001_load.t,v 1.2 2006/09/03 17:13:29 matisse Exp $
# $Revision: 1.2 $
# $Author: matisse $
# $Source: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/t/001_load.t,v $
# $Date: 2006/09/03 17:13:29 $
###############################################################################

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'Perl::Code::Analyze' ); }

my $object = Perl::Code::Analyze->new ();
isa_ok ($object, 'Perl::Code::Analyze');


