# -*- perl -*-
# $Header: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/t/0902_pod_coverage.t,v 1.1 2006/11/26 06:47:43 matisse Exp $
# $Revision: 1.1 $
# $Author: matisse $
# $Source: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/t/0902_pod_coverage.t,v $
# $Date: 2006/11/26 06:47:43 $
###############################################################################

use strict;
use warnings;
use English qw(-no_match_vars);
use Test::More;

eval {
	use Test::Pod::Coverage 1.04;
};

if ( $EVAL_ERROR ) {
    plan skip_all => 'Test::Pod::Coverage required to test POD';
}
else {
    plan tests => 3;
}

pod_coverage_ok( 'Perl::Metrics::Simple' );
pod_coverage_ok( 'Perl::Metrics::Simple::Analysis' );
pod_coverage_ok( 'Perl::Metrics::Simple::Analysis::File' );
