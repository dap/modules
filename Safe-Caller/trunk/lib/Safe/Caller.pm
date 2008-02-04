package Safe::Caller;

use strict;
use warnings;

use Carp ();

our $VERSION = '0.06';

use constant FRAMES => 1;

sub new {
    my ($self, $frames) = @_;
    $frames ||= FRAMES;

    my $caller = sub {
                          my ($f, $elem) = @_;
                          my $frames = defined $f ? $f : $frames;
                          return (caller($frames + 2))[$elem] || '';
                     };

    # all fields required because we need to maintain backwards compatibility
    my @sets = (['package','pkg'], ['filename', 'file'], 'line', ['subroutine', 'sub'],
                 'hasargs', 'wantarray', 'evaltext', 'is_require', 'hints', 'bitmask');

    my $i = 0; my %map;
    foreach my $set (@sets) {
        foreach my $lookup (ref $set eq 'ARRAY' ? @$set : $set) {
            $map{$lookup} = $i;
        }
        $i++;
    }

    my $accessors = {};
    foreach my $type (keys %map) {
        $accessors->{$type} = sub {
                                       my $frames = shift;
                                       return $caller->($frames, $map{$type})
                                  };
    }
    $accessors->{_frames} = $frames;

    return bless $accessors, ref($self) || $self;
}

sub called_from_package {
    my ($self, $called_from_package) = @_;
    Carp::croak 'usage: $caller->called_from_package(\'PACKAGE\');'
      unless defined $called_from_package;

    return $self->{package}->() eq $called_from_package
      ? 1 : 0;
}

sub called_from_filename {
    my ($self, $called_from_filename) = @_;
    Carp::croak 'usage: $caller->called_from_filename(\'file\');'
      unless defined $called_from_filename;

    return $self->{filename}->() eq $called_from_filename
      ? 1 : 0;
}

sub called_from_line {
    my ($self, $called_from_line) = @_;
    Carp::croak 'usage: $caller->called_from_line(13);'
      unless defined $called_from_line && $called_from_line =~ /^\d+$/;

    return $self->{line}->() eq $called_from_line
      ? 1 : 0;
}

sub called_from_subroutine {
    my ($self, $called_from_subroutine) = @_;
    Carp::croak 'usage: $caller->called_from_subroutine(\'sub\');'
      unless defined $called_from_subroutine;

    return $self->{subroutine}->($self->{_frames} + 1) eq $called_from_subroutine
      ? 1 : 0;
}

# backwards compatibility (deprecated)
*called_from_pkg  = \&called_from_package;
*called_from_file = \&called_from_filename;
*called_from_sub  = \&called_from_subroutine;

1;
__END__

=head1 NAME

Safe::Caller - A nicer interface to the built-in caller()

=head1 SYNOPSIS

 package abc;

 use Safe::Caller;

 $caller = Safe::Caller->new;

 a();

 sub a { b() }

 sub b {
     print $caller->{subroutine}->();
     if ($caller->called_from_subroutine('abc::a')) { # do stuff }
 }

=head1 DESCRIPTION

=head1 CONSTRUCTOR

=head2 new

 $caller = Safe::Caller->new(1);

Supplying how many frames to go back while running L<perlfunc/caller> is optional.
By default (if no suitable value is supplied) 1 will be assumed. The default
will be shared among all method calls (accessors & verification routines);
the accessors may optionally accept a frame as parameter, whereas verification
routines (C<called_from_*()>) don't.

=head1 METHODS

=head2 Accessors

 $caller->{package}->();
 $caller->{filename}->();
 $caller->{line}->();
 $caller->{subroutine}->();
 $caller->{hasargs}->();
 $caller->{wantarray}->();
 $caller->{evaltext}->();
 $caller->{is_require}->();
 $caller->{hints}->();
 $caller->{bitmask}->();

See L<perlfunc/caller> for the values they are supposed to return.

=head2 called_from_package

Checks whether the current sub was called within the appropriate package.

 $caller->called_from_package('main');

Returns 1 on success, 0 on failure.

=head2 called_from_filename

Checks whether the current sub was called within the appropriate filename.

 $caller->called_from_filename('foobar.pl');

Returns 1 on success, 0 on failure.

=head2 called_from_line

Checks whether the current sub was called on the appropriate line.

 $caller->called_from_line(13);

Returns 1 on success, 0 on failure.

=head2 called_from_subroutine

Checks whether the current sub was called by the appropriate subroutine.

 $caller->called_from_subroutine('foo');

Returns 1 on success, 0 on failure.

=head1 SEE ALSO

L<perlfunc/caller>, L<Perl6::Caller>, L<Devel::Caller>, L<Sub::Caller>

=head1 AUTHOR

Steven Schubiger <schubiger@cpan.org>

=head1 LICENSE

This program is free software; you may redistribute it and/or
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
