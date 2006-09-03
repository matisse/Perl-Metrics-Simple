package Perl::Code::Analyze;
use strict;
use warnings;

use Carp qw(confess);
use English qw(-no_match_vars);
use File::Find qw(find);
use PPI;
use Readonly;

BEGIN {
    use Exporter ();
    use vars qw( @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
    our $VERSION = '0.01';
    @ISA = qw(Exporter);

    #Give a hoot don't pollute, do not export more than needed by default
    @EXPORT      = qw();
    @EXPORT_OK   = qw();
    %EXPORT_TAGS = ();
}

Readonly::Scalar my $PERL_FILE_REGEX    => qr/ \. p [LlMm] \Z /xm;
Readonly::Scalar my $PERL_SHEBANG_REGEX => qr/ perl /xm;
Readonly::Scalar my $ALL_NEWLINES_REGEX => qr/ ( \n ) /xm;

#################### subroutine header begin ####################

=head2 sample_function

 Usage     : How to use this function/method
 Purpose   : What it does
 Returns   : What it returns
 Argument  : What it wants to know
 Throws    : Exceptions and other anomolies
 Comment   : This is a sample subroutine header.
           : It is polite to include more pod and fewer comments.

See Also   : 

=cut

#################### subroutine header end ####################

sub new {
    my ( $class, %parameters ) = @_;

    my $self = bless( {}, ref($class) || $class );

    return $self;
}

sub analyze_files {
    my ( $self, @dirs_and_files ) = @_;
    my @results = ();
    foreach my $file ( @{ $self->find_files(@dirs_and_files) } ) {
        push @results, $self->analyze_one_file($file);    
    }
    return \@results;
}

sub analyze_one_file {
    my ( $self, $path ) = @_;
    if ( !-r $path ) {
        confess "Path '$path' is not readable!";
    }
    my $document = PPI::Document->new( $path, readonly => 1 );
    $document->index_locations();
    my @subs       = ();
    my $found_subs = $document->find('PPI::Statement::Sub');
    if ($found_subs) {
        foreach my $sub ( @{$found_subs} ) {
            my $sub_length = $self->get_node_length($sub);
            push @subs, { name => $sub->name, length => $sub_length };
        }
    }
    my $found_packages = $document->find('PPI::Statement::Package');
    my @packages       = ();
    if ($found_packages) {
        foreach my $package ( @{$found_packages} ) {
            push @packages, $package->namespace();
        }
    }

    return {
        subs     => \@subs,
        packages => \@packages,
        lines    => $document->last_element->location->[0],
    };
}

sub get_node_length {
    my ( $self, $node ) = @_;
    my $string = $node->content;
    my @newlines = ( $string =~ /$ALL_NEWLINES_REGEX/g );
    return scalar @newlines + 1;
}

sub find_files {
    my $self                  = shift;
    my @directories_and_files = @_;
    foreach my $path (@directories_and_files) {
        if ( !-r $path ) {
            confess "Path '$path' is not readable!";
        }
    }
    my @found = $self->list_files(@directories_and_files);
    return \@found;
}

sub list_files {
    my ( $self, @dirs ) = @_;
    my @files;

    my $wanted = sub {
        push @files, $_ if $self->is_perl_file($_);
    };

    for (@dirs) {
        my $base = $_;
        if ( -d $base ) {
            find( { wanted => $wanted, no_chdir => 1 }, $base );
        }
    }
    return sort @files;
}

sub is_perl_file {
    my ( $self, $path ) = @_;
    return if ( !-f $path );
    return 1 if $path =~ $PERL_FILE_REGEX;
    open my $fh, '<',
      $path || confess "Could not open '$path' for reading: $OS_ERROR";
    my $first_line = <$fh>;
    return 1 if $first_line =~ $PERL_SHEBANG_REGEX;
    return;
}

1;
__END__

#################### main pod documentation begin ###################
## Below is the stub of documentation for your module. 
## You better edit it!


=head1 NAME

Perl::Code::Analyze - Count packages, subs, lines, etc. of many files.

=head1 SYNOPSIS

  use Perl::Code::Analyze;
  blah blah blah


=head1 DESCRIPTION

Stub documentation for this module was created by ExtUtils::ModuleMaker.
It looks like the author of the extension was negligent enough
to leave the stub unedited.

Blah blah blah.


=head1 USAGE



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


