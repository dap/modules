#!/usr/bin/perl

use strict;
use warnings;

use File::Spec;
use FindBin qw($Bin);
use LUGS::Events::Parser;
use Test::More tests => 1;

my $events_file = File::Spec->catfile($Bin, 'data', 'termine.txt');
my $parser = LUGS::Events::Parser->new($events_file);

my @expected = (
    [
      '20080303',
      '2008',
      '03',
      '03',
      '3',
      'Mo',
      '20:00',
      'Linux Stammtisch in Winterthur',
      'winti',
      '<a href="http://www.la-pergola-winti.ch/">Restaurant ' .
        'Pizzeria La Pergola</a>, Stadthausstrasse 71, 8400 ' .
        'Winterthur (<a href="http://map.search.ch/8400-wint' .
        'erthur/stadthausstr.-71">Karte</a>)',
      '<a href="mailto:Paul.Bosshard@LUGS.ch">Paul Bosshard</a>',
      '20080303_0_winti',
    ],
    [
      '20080306',
      '2008',
      '03',
      '06',
      '6',
      'Do',
      '19:30',
      'LugBE Treff',
      'bern',
      'Restaurant Beaulieu, Erlachstrasse 3, 3012 Bern (<a h' .
        'ref="http://map.search.ch/3012-bern/erlachstr.-3">K' .
        'arte</a>)',
      '<a href="mailto:info@lugbe.ch">info@lugbe.ch</a>',
      '20080306_0_bern',
    ],
);

my @events;
while (my $event = $parser->next_event) {
    push @events, [
        $event->get_event_date,
        $event->get_event_year,
        $event->get_event_month,
        $event->get_event_day,
        $event->get_event_simple_day,
        $event->get_event_weekday,
        $event->get_event_time,
        $event->get_event_title,
        $event->get_event_color,
        $event->get_event_location,
        $event->get_event_responsible,
        $event->get_event_anchor,
    ];

}

is_deeply(\@events, \@expected, 'Events parsing');
