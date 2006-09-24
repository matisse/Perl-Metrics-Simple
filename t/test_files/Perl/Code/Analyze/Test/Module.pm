# $Header: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/t/test_files/Perl/Code/Analyze/Test/Module.pm,v 1.5 2006/09/24 16:22:35 matisse Exp $
# $Revision: 1.5 $
# $Author: matisse $
# $Source: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/t/test_files/Perl/Code/Analyze/Test/Module.pm,v $
# $Date: 2006/09/24 16:22:35 $
###############################################################################

# This is a comment. I love comments.

package Perl::Code::Analyze::Test::Module;

use strict;
use warnings;

sub new {
    my ( $class, @args ) = @_;
    my $self = { _args => \@args, };
    return bless $self, $class;
}

sub foo {
    my ($self) = @_;
    foreach my $thing ( @{ $self->{_args} } ) {
        $self->say_hello($thing);
    }
    return $self->{_args};
}

package Perl::Code::Analyze::Test::Module::InnerClass;

sub say_hello {
    my ( $self, $name ) = @_;
    if ( $name && $name ne 'Fred' ) {
        return print "Hello $name\n";
    }
    else {
        return print "Hello Kiddo\n";
    }    
}

package Perl::Code::Analyze::Test::Module;    # back to original package
1;
