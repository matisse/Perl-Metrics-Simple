# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'Perl::Code::Analyze' ); }

my $object = Perl::Code::Analyze->new ();
isa_ok ($object, 'Perl::Code::Analyze');


