#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 14;
use Safe::Caller;

{
    my $caller = Safe::Caller->new;

    my $self = Foo->new($caller);
    my @retval = $self->foo;

    is($retval[0], 'main', '$self->{package}->()');
    is($retval[1], 't/called_from.t', '$self->{filename}->()');
    is($retval[2], '13', '$self->{line}->()');
    is($retval[3], 'Base::foo', '$self->{subroutine}->()');
    is($retval[4], 'main', '$self->{pkg}->() (deprecated)');
    is($retval[5], 't/called_from.t', '$self->{file}->() (deprecated)');
    is($retval[6], 'Base::foo', '$self->{sub}->() (deprecated)');

    $self = Bar->new($caller);
    @retval = $self->foo;

    is($retval[0], 1, 'called_from_package()');
    is($retval[1], 1, 'called_from_filename()');
    is($retval[2], 1, 'called_from_line()');
    is($retval[3], 1, 'called_from_subroutine()');
    is($retval[4], 1, 'called_from_pkg() (deprecated)');
    is($retval[5], 1, 'called_from_file() (deprecated)');
    is($retval[6], 1, 'called_from_sub() (deprecated)');
}

package Base;

sub new {
    my ($self, $caller) = @_;
    my $class = ref($self) || $self;
    return bless { caller => $caller }, $class;
}

sub foo {
    my ($self) = @_;
    return $self->bar;
}

package Foo;

use base qw(Base);

sub bar {
    my ($self) = @_;
    return map { $self->{caller}->{$_}->() } qw(package filename line subroutine pkg file sub);
}

package Bar;

use base qw(Base);

sub bar {
    my ($self) = @_;
    return ($self->{caller}->called_from_package('Base'),
            $self->{caller}->called_from_filename('t/called_from.t'),
            $self->{caller}->called_from_line(45),
            $self->{caller}->called_from_subroutine('Base::foo'),
            $self->{caller}->called_from_pkg('Base'),
            $self->{caller}->called_from_file('t/called_from.t'),
            $self->{caller}->called_from_sub('Base::foo'));
}
