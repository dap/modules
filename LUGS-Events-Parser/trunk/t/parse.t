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
      '<a href="http://www.la-pergola-winti.ch/">Restaurant Pizzeria La Per' .
        'gola</a>, Stadthausstrasse 71, 8400 Winterthur (<a href="http://ma' .
        'p.search.ch/8400-winterthur/stadthausstr.-71">Karte</a>)',
      '<a href="mailto:Paul.Bosshard@LUGS.ch">Paul Bosshard</a>',
      '<a href="/lugs/sektionen/winterthur.phtml">Mehr Infos</a>',
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
      'Restaurant Beaulieu, Erlachstrasse 3, 3012 Bern (<a href="http://map' .
        '.search.ch/3012-bern/erlachstr.-3">Karte</a>)',
      '<a href="mailto:info@lugbe.ch">info@lugbe.ch</a>',
      '<a href="http://lugbe.ch/action/nexttreff.phtml">Mehr Infos</a>',
      '20080306_0_bern',
    ],
    [
      '20090709',
      '2009',
      '07',
      '09',
      '9',
      'Do',
      '19:15',
      'LUGS Treff',
      'treff',
      'ETH Z&uuml;rich, <a href="http://www.rauminfo.ethz.ch/grundrissplan.' .
        'gif?region=Z&areal=Z&gebaeude=HG&geschoss=G&raumNr=26.5">HG G 26.5' .
        '</a> (<font color="red"><b>anderer Raum!</b></font>)',
      '<a href="mailto:lugsvs@lugs.ch">LUGS Vorstand</a>',
      'Restaurant nach dem Treff: <a href="http://www.doodle' .
        '.com/mgfpebmxx5ibyt4m">' .
        'Auswahl / Anmeldung</a> (bis 09.07.2009 12:00)',
      '20090709_0_treff',
    ],
    [
      '20090725',
      '2009',
      '07',
      '25',
      '25',
      'Sa',
      'ab 17:00',
      'LUGS Grillabend',
      'spec',
      'H&uuml;tte/Areal des Sch&auml;ferhundeclubs Winterthur (<a href="htt' .
        'p://neil.franklin.ch/Info_Texts/Anreise_SCOG_Clubhaus.html">Anreis' .
        'e</a>)',
      '<a href="mailto:neil@franklin.ch">Neil Franklin</a>',
      'Wie schon die letzten Jahre werden wir auch dieses Jahr wieder eine ' .
        'LUGS-Grillparty durchf&uuml;hren. <br>Teilnehmer: LUGS Mitglieder ' .
        '(und werdende), Familie (Freund(in), Kinder, Geschwister, ...), Fr' .
        'eunde, ... <br><a href="https://www.lugs.ch/lugs/interna/maillugs/' .
        '200907/42.html">Mehr Infos</a> (nur mit <a href="https://www.lugs.' .
        'ch/lugs/badpw.phtml">LUGS Login</a>)',
      '20090725_0_spec',
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
        $event->get_event_more,
        $event->get_event_anchor,
    ];
}

is_deeply(\@events, \@expected, 'Events parsing');
