# $Header: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/lib/Perl/Code/Analyze/Attic/Analysis.pm,v 1.2 2006/09/05 15:34:27 matisse Exp $
# $Revision: 1.2 $
# $Author: matisse $
# $Source: /Users/matisse/Desktop/CVS2GIT/matisse.net.cvs/Perl-Metrics-Simple/lib/Perl/Code/Analyze/Attic/Analysis.pm,v $
# $Date: 2006/09/05 15:34:27 $
###############################################################################

package Perl::Code::Analyze::Analysis;
use strict;
use warnings;

use Carp qw(confess);
use English qw(-no_match_vars);
use Readonly;

our $VERSION = '0.01';

my %AnalysisData = ();
my %Files        = ();
my %Lines        = ();
my %Packages     = ();
my %Subs         = ();

sub new {
    my ( $class, $analysis_data ) = @_;
    if (
        !(
                $analysis_data
            and ref $analysis_data
            and ref $analysis_data eq 'ARRAY'
        )
      )
    {
        confess 'Did not supply an arryref of analysis data.';
    }
    my $self = {};
    bless $self, ref $class || $class;
    $self->_init($analysis_data);    # Load object properties
    return $self;
}

sub files {
    my ($self) = @_;
    return $Files{$self};
}

sub data {
    my $self = shift;
    return $AnalysisData{$self};
}

sub file_count {
    my $self = shift;
    return scalar @{ $self->files };
}

sub lines {
    my $self = shift;
    return $Lines{$self};
}    

sub packages {
    my ($self) = @_;
    return $Packages{$self};
}

sub package_count {
    my $self = shift;
    return scalar @{ $self->packages };
}

sub subs {
    my ($self) = @_;
    return $Subs{$self};
}

sub sub_count {
    my $self = shift;
    return scalar @{ $self->subs };
}

sub _init {
    my ( $self, $analysis_data ) = @_;
    $AnalysisData{$self} = $analysis_data;

    my @files    = ();
    my @packages = ();
    my $lines    = 0;
    my @subs;
    foreach my $result ( @{ $self->data() } ) {
        $lines += $result->{lines};
        push @files, $result->{file_path};
        foreach my $package ( @{ $result->{packages} } ) {
            push @packages, $package;
        }
        foreach my $sub ( @{ $result->{subs} } ) {
            push @subs, $sub;
        }
    }
    $Files{$self}    = \@files;
    $Packages{$self} = \@packages;
    $Lines{$self}    = $lines;
    $Subs{$self}     = \@subs;
    return 1;
}
1;
__END__

#################### main pod documentation begin ###################
## Below is the stub of documentation for your module. 
## You better edit it!


=head1 NAME

Perl::Code::Analyze::Analysis - Contains anaylsis results.

=head1 SYNOPSIS

This is the class of objects returned by the I<analyze_files>
and I<analyze_one_file> methods of the B<Perl::Code::Analyze> class.


=head1 DESCRIPTION

Stub documentation for this module was created by ExtUtils::ModuleMaker.
It looks like the author of the extension was negligent enough
to leave the stub unedited.

Blah blah blah.


=head1 USAGE



=head2 new

 Usage     : How to use this function/method
 Purpose   : What it does
 Returns   : What it returns
 Argument  : What it wants to know
 Throws    : Exceptions and other anomolies
 Comment   : This is a sample subroutine header.
           : It is polite to include more pod and fewer comments.

See Also   : 

=head2 data

=head2 files

=head2 file_count

=head2 lines

Total lines in all files, including comments.

=head2 packages

Unique packages found in code.

=head2 packge_count

=head2 subs

Array ref containing names of all naed subroutines,
in the order encounted.

=head2 sub_count

=head1 BUGS

=head1 SUPPORT

=head1 AUTHOR

    Matisse Enzer
    CPAN ID: MATISSE
    Eigenstate Consulting, LLC
    matisse@eigenstate.net
    http://www.eigenstate.net/

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.


=head1 SEE ALSO

perl(1).

=cut

#################### main pod documentation end ###################


