# $Header: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/t/test_files/Perl/Code/Analyze/Test/Module.pm,v 1.7 2006/11/23 22:25:48 matisse Exp $
# $Revision: 1.7 $
# $Author: matisse $
# $Source: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/t/test_files/Perl/Code/Analyze/Test/Module.pm,v $
# $Date: 2006/11/23 22:25:48 $
###############################################################################

# This is a comment. I love comments.

package Perl::Metrics::Simple::Test::Module;

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
        next if ( $thing eq 'goodbye' );
        last if ( $thing eq 'bailout' );
    }
    return $self->{_args};
}

package Perl::Metrics::Simple::Test::Module::InnerClass;

sub say_hello {
    my ( $self, $name ) = @_;
    if ( $name && $name ne 'Fred' ) {
        return print "Hello $name\n";
    }
    else {
        return print "Hello Kiddo\n";
    }    
}

package Perl::Metrics::Simple::Test::Module;    # back to original package
1;
