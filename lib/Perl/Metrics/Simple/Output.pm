package Perl::Metrics::Simple::Output;

our $VERSION = '0.19';

use strict;
use warnings;

use Carp qw();

sub new {
    my ( $class, $analysis ) = @_;

    my $self = bless {
        _analysis => $analysis,
    }, $class;

    return $self;
}

sub analysis {
    my ($self) = @_;
    return $self->{'_analysis'};
}

sub make_report {
    Carp::confess('Use one of the sub-classes, e.g. Perl::Metrics::Simple::Output::PlainText');
}

1;    # Keep Perl happy, snuggy, and warm.

__END__

=pod

=head1 NAME

Perl::Metrics::Simple::Output - Base class for output classes

=head1 SYNOPSIS

Use one of the sub-classes, e.g. B<Perl::Metrics::Simple::Output::PlainText>

=cut
