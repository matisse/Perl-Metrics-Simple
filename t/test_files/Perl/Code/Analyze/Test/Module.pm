# $Header: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/t/test_files/Perl/Code/Analyze/Test/Module.pm,v 1.2 2006/09/03 17:13:29 matisse Exp $
# $Revision: 1.2 $
# $Author: matisse $
# $Source: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/t/test_files/Perl/Code/Analyze/Test/Module.pm,v $
# $Date: 2006/09/03 17:13:29 $
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