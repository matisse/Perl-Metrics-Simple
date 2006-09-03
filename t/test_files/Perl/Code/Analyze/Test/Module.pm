# This is a comment. I love comments.

package Perl::Code::Analyze::Test::Module;

use strict;
use warnings;


sub new {
    my ( $class, @args ) = @_;
    my $self = { _args => \@args, };
    bless $self, $class;
}

sub args {
    my ($self) = @_;
    return $self->{_args};
}    

package Perl::Code::Analyze::Test::Module::InnerClass;
sub say_hello {
    my ($self) = @_;
    return print "Hello Dolly\n";
}

1;