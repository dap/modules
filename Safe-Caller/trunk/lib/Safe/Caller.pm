package Safe::Caller;

use strict;
use warnings;

our $VERSION = '0.03';

sub new {
    my ($self, $frames) = @_;
    my $class = ref($self) || $self;
    $frames ||= 2;
    return bless { pkg        => sub { my $frames = $_[0] || $frames; (caller($frames))[0] },
                   file       => sub { my $frames = $_[0] || $frames; (caller($frames))[1] },
		   line       => sub { my $frames = $_[0] || $frames; (caller($frames))[2] },
		   sub        => sub { my $frames = $_[0] || $frames; (caller($frames))[3] },
		   hasargs    => sub { my $frames = $_[0] || $frames; (caller($frames))[4] },
		   wantarray  => sub { my $frames = $_[0] || $frames; (caller($frames))[5] },
		   evaltext   => sub { my $frames = $_[0] || $frames; (caller($frames))[6] },
		   is_require => sub { my $frames = $_[0] || $frames; (caller($frames))[7] },
		   hints      => sub { my $frames = $_[0] || $frames; (caller($frames))[8] },
		   bitmask    => sub { my $frames = $_[0] || $frames; (caller($frames))[9] }, }, $class;
}

sub called_from_pkg {
    my ($self, $called_from_pkg) = @_;
    return $self->{pkg}->(2) eq $called_from_pkg 
      ? 1 : 0;
}

sub called_from_file {
    my ($self, $called_from_file) = @_;
    return $self->{file}->(2) eq $called_from_file 
      ? 1 : 0;
}

sub called_from_line {
    my ($self, $called_from_line) = @_;
    return $self->{line}->(2) eq $called_from_line 
      ? 1 : 0;
}

sub called_from_sub {
    my ($self, $called_from_sub) = @_;
    return $self->{sub}->(2) eq $called_from_sub 
      ? 1 : 0;
}

1;
__END__

=head1 NAME

Safe::Caller - A nicer interface to caller() with code execution restriction 

=head1 SYNOPSIS

 use Safe::Caller;

 $safe = Safe::Caller->new;
  
 package Foo;
 
 foo();
  
 sub foo { bar() }
  
 sub bar { 
     print $safe->{sub}->();
     if ($safe->called_from_sub('Foo::foo')) { do something }
 }

=head1 DESCRIPTION

=head1 CONSTRUCTOR

=head2 new
 
 $safe = Safe::Caller->new(2);
 
Supplying how many frames to go back while running C<caller()> is optional. 
By default (if no suitable value is supplied) 2 will be assumed.

=head1 METHODS

=head2 called_from_pkg

Checks whether the current sub was called within the appropriate package.

 $safe->called_from_pkg('main');
 
Returns 1 on success, 0 on failure.

=head2 called_from_file

Checks whether the current sub was called by the appropriate file.

 $safe->called_from_file('foobar.pl');
 
Returns 1 on success, 0 on failure.

=head2 called_from_line

Checks whether the current sub was called on the appropriate line.

 $safe->called_from_line(13);
 
Returns 1 on success, 0 on failure.

=head2 called_from_sub

Checks whether the current sub was called by the appropriate subroutine.

 $safe->called_from_sub('foo');
 
Returns 1 on success, 0 on failure.

=head1 SEE ALSO

L<caller>

=head1 AUTHOR

Steven Schubiger <schubiger@cpan.org>

=head1 LICENSE

This program is free software; you may redistribute it and/or 
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>	    

=cut
