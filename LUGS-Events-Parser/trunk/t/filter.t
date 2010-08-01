#!/usr/bin/perl

use strict;
use warnings;
use boolean qw(true);

use File::Spec;
use FindBin qw($Bin);
use LUGS::Events::Parser;
use Test::More tests => 1;

my $events_file = File::Spec->catfile($Bin, 'data', 'termine.txt');
my $parser = LUGS::Events::Parser->new($events_file, {
    filter_html  => true,
    tag_handlers => {
        'a href' => [ {
            rewrite => '$TEXT - $HREF',
            fields  => [ qw(location responsible) ],
        }, {
            rewrite => '$TEXT - $HREF',
            fields  => [ qw(more) ],
        } ],
        'font color' => [ {
             rewrite => '$TEXT',
             fields  => [ '*' ],
        } ],
        'b' => [ {
            rewrite => '$TEXT',
            fields  => [ '*' ],
        } ],
        'br' => [ {
            rewrite => '',
            fields  => [ '*' ],
        } ],
    },
    strip_text => [ 'mailto:' ],
});

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
      'Restaurant Pizzeria La Pergola - http://www.la-pergola-winti.ch/' .
        ', Stadthausstrasse 71, 8400 Winterthur (Karte - http://map.sea' .
        'rch.ch/8400-winterthur/stadthausstr.-71)',
      'Paul Bosshard - Paul.Bosshard@LUGS.ch',
      'Mehr Infos - /lugs/sektionen/winterthur.phtml',
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
      'Restaurant Beaulieu, Erlachstrasse 3, 3012 Bern (Karte - http://' .
        'map.search.ch/3012-bern/erlachstr.-3)',
      'info@lugbe.ch - info@lugbe.ch',
      'Mehr Infos - http://lugbe.ch/action/nexttreff.phtml',
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
      'ETH Zürich, HG G 26.5 - http://www.rauminfo.ethz.ch/grundrisspla' .
        'n.gif?region=Z&areal=Z&gebaeude=HG&geschoss=G&raumNr=26.5 (and' .
        'erer Raum!)',
      'LUGS Vorstand - lugsvs@lugs.ch',
      'Restaurant nach dem Treff: Auswahl / Anmeldung - http://www.dood' .
        'le.com/mgfpebmxx5ibyt4m (bis 09.07.2009 12:00)',
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
      'Hütte/Areal des Schäferhundeclubs Winterthur (Anreise - http://n' .
        'eil.franklin.ch/Info_Texts/Anreise_SCOG_Clubhaus.html)',
      'Neil Franklin - neil@franklin.ch',
      'Wie schon die letzten Jahre werden wir auch dieses Jahr wieder e' .
        'ine LUGS-Grillparty durchführen. Teilnehmer: LUGS Mitglieder (' .
        'und werdende), Familie (Freund(in), Kinder, Geschwister, ...),' .
        ' Freunde, ... Mehr Infos - https://www.lugs.ch/lugs/interna/ma' .
        'illugs/200907/42.html (nur mit LUGS Login - https://www.lugs.c' .
        'h/lugs/badpw.phtml)',
      '20090725_0_spec',
    ],
    [
      '20100212',
      '2010',
      '02',
      '12',
      '12',
      'Fr',
      '19:15',
      'LUGS Treff - Voodoo, Schwarze Magie und Internet per UMTS',
      'treff',
      'Solino - http://www.solino.ch/, Am Schanzengraben 15, 8002 Züric' .
        'h (Karte - http://map.search.ch/zuerich/am-schanzengraben-15)',
      'Martin Ebnöther - ventilator@semmel.ch',
      undef,
      '20100212_0_treff',
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

is_deeply(\@events, \@expected, 'Events parsing with HTML filtering');
