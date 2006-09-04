#!/usr/bin/perl
# $Header: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/t/test_files/subs_no_package.pl,v 1.3 2006/09/04 01:40:36 matisse Exp $
# $Revision: 1.3 $
# $Author: matisse $
# $Source: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/t/test_files/subs_no_package.pl,v $
# $Date: 2006/09/04 01:40:36 $
###############################################################################

use strict;
use warnings;

print "Hello world.\n";

my $code_ref = sub { print "Hi there\n"; }; # Will not be counted
exit;

sub foo {};
sub bar {
    # This is the second line of the sub
    
    # This is the fourth line of the sub
}