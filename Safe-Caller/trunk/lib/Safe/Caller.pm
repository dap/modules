package Safe::Caller;

use strict;
use warnings;

use Carp ();

use constant FRAMES => 2;

our $VERSION = '0.04';

sub new {
    my ($self, $frames) = @_;

    my $class = ref($self) || $self;
    $frames ||= FRAMES;

    return bless { pkg        => sub { my $frames = defined $_[0] ? $_[0] : $frames; (caller($frames))[0] },
                   file       => sub { my $frames = defined $_[0] ? $_[0] : $frames; (caller($frames))[1] },
                   line       => sub { my $frames = defined $_[0] ? $_[0] : $frames; (caller($frames))[2] },
                   sub        => sub { my $frames = defined $_[0] ? $_[0] : $frames; (caller($frames))[3] },
                   hasargs    => sub { my $frames = defined $_[0] ? $_[0] : $frames; (caller($frames))[4] },
                   wantarray  => sub { my $frames = defined $_[0] ? $_[0] : $frames; (caller($frames))[5] },
                   evaltext   => sub { my $frames = defined $_[0] ? $_[0] : $frames; (caller($frames))[6] },
                   is_require => sub { my $frames = defined $_[0] ? $_[0] : $frames; (caller($frames))[7] },
                   hints      => sub { my $frames = defined $_[0] ? $_[0] : $frames; (caller($frames))[8] },
                   bitmask    => sub { my $frames = defined $_[0] ? $_[0] : $frames; (caller($frames))[9] }}, $class;
}

sub called_from_pkg {
    my ($self, $called_from_pkg) = @_;
    Carp::croak 'usage: $safe->called_from_pkg(\'PACKAGE\');'
      unless defined $called_from_pkg;

    return $self->{pkg}->() eq $called_from_pkg
      ? 1 : 0;
}

sub called_from_file {
    my ($self, $called_from_file) = @_;
    Carp::croak 'usage: $safe->called_from_file(\'file\');'
      unless defined $called_from_file;

    return $self->{file}->() eq $called_from_file
      ? 1 : 0;
}

sub called_from_line {
    my ($self, $called_from_line) = @_;
    Carp::croak 'usage: $safe->called_from_line(42);'
      unless defined $called_from_line && $called_from_line =~ /^\d+$/;

    return $self->{line}->() eq $called_from_line
      ? 1 : 0;
}

sub called_from_sub {
    my ($self, $called_from_sub) = @_;
    Carp::croak 'usage: $safe->called_from_sub(\'sub\');'
      unless defined $called_from_sub;

    return $self->{sub}->() eq $called_from_sub
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
     if ($safe->called_from_sub('Foo::foo')) { # do stuff }
 }

=head1 DESCRIPTION

=head1 CONSTRUCTOR

=head2 new

 $safe = Safe::Caller->new(2);

Supplying how many frames to go back while running L<perlfunc/caller> is optional.
By default (if no suitable value is supplied) 2 will be assumed. The default
will be shared among all method calls (accessors & verification routines);
the accessors may optionally accept a frame as parameter, whereas verification
routines (C<called_from_*()>) don't.

=head1 METHODS

=head2 Accessors

 $safe->{pkg}->();
 $safe->{file}->();
 $safe->{line}->();
 $safe->{sub}->();
 $safe->{hasargs}->();
 $safe->{wantarray}->();
 $safe->{evaltext}->();
 $safe->{is_require}->();
 $safe->{hints}->();
 $safe->{bitmask}->();

See L<perlfunc/caller> for the values they are supposed to return.

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

L<perlfunc/caller>

=head1 AUTHOR

Steven Schubiger <schubiger@cpan.org>

=head1 LICENSE

This program is free software; you may redistribute it and/or
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
