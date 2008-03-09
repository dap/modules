package LUGS::Events::Parser;

use strict;
use warnings;

use Carp qw(croak);

our $VERSION = '0.01';

sub new
{
    my $class = shift;

    my $self = bless {}, ref($class) || $class;
    $self->_init(@_);

    $self->_fetch_content;
    $self->_parse_content;

    return $self;
}

sub _init
{
    my ($self, $file) = @_;

    if (defined $file) {
        croak "'$file': $!" unless -f $file;
    }
    else {
        croak 'new(): requires valid absolute path to events file';
    }

    $self->{Input} = $file;
}

sub _fetch_content
{
    my $self = shift;

    open (my $fh, '<', $self->{Input}) or die "Can't open $self->{Input}: $!\n";
    $self->{content} = do { local $/; <$fh> };
    close($fh);
}

sub _parse_content
{
    my $self = shift;

    my @events = $self->{content} =~ /(^event .*? ^endevent)/gmsx;
    my @data;

    foreach my $event (@events) {
        my @fields = split /\n/, $event;
        my (%fields, %seen);

        foreach my $field (@fields) {
            if (my ($text) = $field =~ /^event \s+ (.*)/x) {
                $fields{event} = $text;
            }
            elsif ($field =~ /^endevent \z/x) {
                last;
            }
            else {
                my ($fieldname, $text) = $field =~ /^ \s+ (\w+?) \s+ (.*)/x;
                $seen{$fieldname} ||= '';
                $fields{$fieldname} .= $seen{$fieldname} ? " $text" : $text;
                $seen{$fieldname} = 1;
            }
        }

        push @data, LUGS::Events::Parser::Event->new(%fields);
    }

    $self->{data} = \@data;
}

sub next_event
{
    my $self = shift;

    return shift @{$self->{data}};
}

1;

package LUGS::Events::Parser::Event;

sub new
{
    my $class = shift;

    return bless { event => { @_ } }, ref($class) || $class;
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

1;
__END__

=head1 NAME

LUGS::Events::Parser - Event parser for the Linux User Group Switzerland

=head1 SYNOPSIS

 use LUGS::Events::Parser;

 $parser = LUGS::Events::Parser->new($events_file);

 while ($event = $parser->next_event) {
     $date = $event->get_event_date;
     ...
 }

=head1 DESCRIPTION

C<LUGS::Events::Parser> parses the events CSV file of the Linux User Group
Switzerland (LUGS) and offers according accessor methods.

=head1 CONSTRUCTOR

=head2 new

Creates a new C<LUGS::Events::Parser> object.

 $parser = LUGS::Events::Parser->new('/path/to/events_file');

=head1 METHODS

=head2 next_event

 $event = $parser->next_event;

Returns a C<LUGS::Events::Parser::Event> object.

=head2 get_event_date

 $date = $event->get_event_date;

Fetch the full 'event' date field.

=head2 get_event_year

 $year = $event->get_event_year;

Fetch the event year.

=head2 get_event_month

 $month = $event->get_event_month;

Fetch the event month.

=head2 get_event_day

 $day = $event->get_event_day;

Fetch the event day.

=head2 get_event_simple_day

 $simple_day = $event->get_event_simple_day;

Fetch the event 'day' field (without zeroes).

=head2 get_event_weekday

 $weekday = $event->get_event_weekday;

Fetch the event 'weekday' field.

=head2 get_event_time

 $time = $event->get_event_time;

Fetch the event 'time' field.

=head2 get_event_title

 $title = $event->get_event_title;

Fetch the event 'title' field.

=head2 get_event_color

 $color = $event->get_event_color;

Fetch the event 'color' field.

=head2 get_event_location

 $location = $event->get_event_location;

Fetch the event 'location' field.

=head2 get_event_responsible

 $responsible = $event->get_event_responsible;

Fetch the event 'responsible' field.

=head2 get_event_more

 $more = $event->get_event_more;

Fetch the event 'more' field.

=head1 AUTHOR

Steven Schubiger <schubiger@cpan.org>

=head1 LICENSE

This program is free software; you may redistribute it and/or
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
