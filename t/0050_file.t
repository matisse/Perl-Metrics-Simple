# $Header$
# $Revision$
# $Author$
# $Source$
# $Date$
###############################################################################

use strict;
use warnings;
use English qw(-no_match_vars);
use Data::Dumper;
use FindBin qw($Bin);
use lib "$Bin/lib";

use PPI;
use Perl::Metrics::Simple::Analysis::File;

use Test::More tests => 11;

test_is_hash_key();

exit;

#  is_hash_key tests

# Copied from
# http://search.cpan.org/src/THALJEF/Perl-Critic-0.21/t/05_utils.t
sub test_is_hash_key {
   my $code = 'sub foo { return $hash1{bar}, $hash2->{baz}; }';
   my $doc = PPI::Document->new(\$code);
   my @words = @{$doc->find('PPI::Token::Word')};
   my @expect = (
      ['sub', undef],
      ['foo', undef],
      ['return', undef],
      ['bar', 1],
      ['baz', 1],
   );
   is(scalar @words, scalar @expect, 'is_hash_key count');
   for my $i (0 .. $#expect)
   {
      is($words[$i], $expect[$i][0], 'is_hash_key word');
      is(Perl::Metrics::Simple::Analysis::File::is_hash_key($words[$i]), $expect[$i][1], 'is_hash_key boolean');
   }
}