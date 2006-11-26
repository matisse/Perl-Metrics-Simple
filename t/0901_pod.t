# -*- perl -*-
# $Header: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/t/0901_pod.t,v 1.1 2006/11/26 06:47:43 matisse Exp $
# $Revision: 1.1 $
# $Author: matisse $
# $Source: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/t/0901_pod.t,v $
# $Date: 2006/11/26 06:47:43 $
###############################################################################

use strict;
use warnings;
use Test::More;

eval 'use Test::Pod 1.00';  ## no critic
plan skip_all => 'Test::Pod 1.00 required for testing POD' if $@;
all_pod_files_ok();
