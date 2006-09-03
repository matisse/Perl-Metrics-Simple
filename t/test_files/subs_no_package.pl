#!/usr/bin/perl
# $Header: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/t/test_files/subs_no_package.pl,v 1.2 2006/09/03 17:13:29 matisse Exp $
# $Revision: 1.2 $
# $Author: matisse $
# $Source: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/t/test_files/subs_no_package.pl,v $
# $Date: 2006/09/03 17:13:29 $
###############################################################################

use strict;
use warnings;

print "Hello world.\n";

exit;

sub foo {};
sub bar {
    # This is the second line of the sub
    
    # This is the fourth line of the sub
}