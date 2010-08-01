package LUGS::Events::Parser::Event;

use strict;
use warnings;

our $VERSION = '0.03';

sub new
{
    my $class = shift;

    return bless { event => { @_ } }, $class;
}

sub get_event_date
{
    my $self = shift;

    return $self->{event}->{event};
}

sub get_event_year
{
    my $self = shift;

    return substr($self->{event}->{event}, 0, 4);
}

sub get_event_month
{
    my $self = shift;

    return substr($self->{event}->{event}, 4, 2);
}

sub get_event_day
{
    my $self = shift;

    return substr($self->{event}->{event}, 6, 2);
}

sub get_event_simple_day
{
    my $self = shift;

    return $self->{event}->{day};
}

sub get_event_weekday
{
    my $self = shift;

    return $self->{event}->{weekday};
}

sub get_event_time
{
    my $self = shift;

    return $self->{event}->{time};
}

sub get_event_title
{
    my $self = shift;

    return $self->{event}->{title};
}

sub get_event_color
{
    my $self = shift;

    return $self->{event}->{color};
}

sub get_event_location
{
    my $self = shift;

    return $self->{event}->{location};
}

sub get_event_responsible
{
    my $self = shift;

    return $self->{event}->{responsible};
}

sub get_event_more
{
    my $self = shift;

    return $self->{event}->{more};
}

sub get_event_anchor
{
    my $self = shift;

    my ($event, $color) = map $self->{event}->{$_}, qw(event color);
    my $id = $self->{anchors}{$event}->{$color}++;

    return join '_', ($event, $id, $color);
}

1;
