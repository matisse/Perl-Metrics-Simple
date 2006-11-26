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
use Readonly;
use Test::More tests => 14;

Readonly::Scalar my $TEST_DIRECTORY => "$Bin/test_files";
Readonly::Scalar my $EMPTY_STRING   => q{};
test_measure_complexity();
test_is_hash_key();

exit;

sub test_measure_complexity {
    my $test_file = "$TEST_DIRECTORY/not_a_perl_file";
    my $file_counter = Perl::Metrics::Simple::Analysis::File->new( path => $test_file);
    my $all_comment_code = q{# this is a comment. I love comments.};
    my $all_comment_doc = PPI::Document->new(\$all_comment_code);
    my $all_comment_complexity = $file_counter->measure_complexity($all_comment_doc);
    is($all_comment_complexity,0,'Complexity of all-comment code is 0'); 

    my $print_statement_code = 'print "Hello world.\n";';
    my $print_statement_doc  = PPI::Document->new(\$print_statement_code);
    my $print_statement_complexity = $file_counter->measure_complexity($print_statement_doc);
    is($print_statement_complexity,1,'Complexity of print statement is 1');
    
    my $basic_if_code = 'if ($a > $b) { return 1; }';
    my $basic_if_doc  = PPI::Document->new(\$basic_if_code);
    my $basic_if_complexity = $file_counter->measure_complexity($basic_if_doc);
    is($basic_if_complexity,2,'Complexity of basic "if" block is 2');
    return 1;
}

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