#!/usr/bin/perl

use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../lib";
use Perl::Metrics::Simple;

use Test::More tests => 5;

my $CLASS_TO_TEST = 'Perl::Metrics::Simple::Output';

use_ok($CLASS_TO_TEST);

test_modifier( after => q{foo} );

test_modifier( after => q{'foo'} );

test_modifier( after => q{"foo"} );

test_modifier( after => q< qq[foo] >);

exit;

sub test_modifier {
	my ( $modifier, $modificand ) = @_;
	my $code = qq[
		$modifier $modificand => sub {
			return "modified";
		};
	];
	diag $code;
	my $analyzer = Perl::Metrics::Simple->new;
	my $analysis = eval { $analyzer->analyze_files( \$code ) } or diag $@;
	isa_ok( $analysis, 'Perl::Metrics::Simple::Analysis' );
}



