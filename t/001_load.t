# -*- perl -*-
# $Header: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/t/001_load.t,v 1.3 2006/10/03 03:53:08 matisse Exp $
# $Revision: 1.3 $
# $Author: matisse $
# $Source: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/t/001_load.t,v $
# $Date: 2006/10/03 03:53:08 $
###############################################################################

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'Perl::Metrics::Simple' ); }

my $object = Perl::Metrics::Simple->new ();
isa_ok ($object, 'Perl::Metrics::Simple');


