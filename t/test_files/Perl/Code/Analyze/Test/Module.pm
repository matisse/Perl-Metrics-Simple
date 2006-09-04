# $Header: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/t/test_files/Perl/Code/Analyze/Test/Module.pm,v 1.3 2006/09/04 01:40:36 matisse Exp $
# $Revision: 1.3 $
# $Author: matisse $
# $Source: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/t/test_files/Perl/Code/Analyze/Test/Module.pm,v $
# $Date: 2006/09/04 01:40:36 $
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
    return $self->{_args};
}    

package Perl::Code::Analyze::Test::Module::InnerClass;
sub say_hello {
    my ($self) = @_;
    return print "Hello Dolly\n";
}
package Perl::Code::Analyze::Test::Module; # back to original package
1;