# This is a comment. I love comments.

package Perl::Metrics::Simple::Test::Moose;

use Moose;

sub foo {
    return 42;
}

sub _after_bar {
    print 43;
}

1;
