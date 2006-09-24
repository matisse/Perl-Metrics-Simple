#!/usr/bin/perl
# $Header: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/t/test_files/package_no_subs.pl,v 1.3 2006/09/24 16:22:35 matisse Exp $
# $Revision: 1.3 $
# $Author: matisse $
# $Source: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/t/test_files/package_no_subs.pl,v $
# $Date: 2006/09/24 16:22:35 $
###############################################################################

package Hello::Dolly;

use strict;
use warnings;

print "Hello world.\n";
print "I have a package.\n";
print "I have no subs.\n";

for ( 1..5 ) {
    print "$_\n";
}

exit;