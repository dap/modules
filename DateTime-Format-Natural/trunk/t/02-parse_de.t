#!/usr/bin/perl

use strict;
use warnings;

use DateTime::Format::Natural;
use Test::More tests => 40;

my ($sec, $min, $hour, $day, $month, $year) = (00, 13, 01, 24, 11, 2006);

my %simple = ('Donnerstag'               => '23.11.2006 01:13:00',
              'November'                 => '24.11.2006 01:13:00',
              'Freitag 13:00'            => '24.11.2006 13:00:00',
              'Mon 2:35'                 => '20.11.2006 02:35:00',
              '16:00 Uhr'                => '24.11.2006 16:00:00',
              '6 am Morgen'              => '24.11.2006 06:00:00',
              'Samstag 7 am Abend'       => '25.11.2006 19:00:00',
              'Gestern'                  => '23.11.2006 01:13:00',
              'Heute'                    => '24.11.2006 01:13:00',
              'Morgen'                   => '25.11.2006 01:13:00',
              'Diesen Dienstag'          => '21.11.2006 01:13:00',
              'Nächster Monat'           => '24.12.2006 01:13:00',
              'Morgen'                   => '24.11.2006 08:00:00',
              'Sekunde'                  => '24.11.2006 01:13:00',
              'Gestern um 4:00'          => '23.11.2006 04:00:00',
              'Letzten Freitag um 20:00' => '17.11.2006 20:00:00',
              'morgen um 18:45'          => '25.11.2006 18:45:00',
              'Gestern nachmittag'       => '23.11.2006 14:00:00',
              'Donnerstag letzte Woche'  => '16.11.2006 01:13:00');

my %complex = ('25 Sekunden her'              => '24.11.2006 01:12:35',
               '10 Minuten her'               => '24.11.2006 01:03:00',
               '3 Jahre her'                  => '24.11.2003 01:13:00',
               '5 Monate vor jetzt'           => '24.06.2006 01:13:00',
               '7 Stunden her'                => '23.11.2006 18:13:00',
               'in 3 Stunden'                 => '24.11.2006 04:13:00',
               'morgen 1 Jahr her'            => '25.11.2005 01:13:00',
               'Samstag 3 Tage her um 17:00'  => '22.11.2006 17:00:00',
               '4 Tag letzte Woche'           => '16.11.2006 01:13:00',
               '3 Mittwoch in November'       => '15.11.2006 01:13:00',
               '3 Monat nächstes Jahr'        => '24.03.2007 01:13:00');

my %specific = ('Januar 5'         => '05.01.2006 01:13:00',
                'dez 25'           => '25.12.2006 01:13:00',
                'mai 27'           => '27.05.2006 01:13:00',
                'Oktober 2006'     => '24.10.2006 01:13:00',
                'Februar 14, 2004' => '14.02.2004 01:13:00',
                'Freitag'          => '24.11.2006 01:13:00',
                'jan 3 2010'       => '03.01.2010 01:13:00',
                '3 jan 2000'       => '03.01.2000 01:13:00',
                '27/5/1979'        => '27.05.1979 01:13:00',
                '4:00'             => '24.11.2006 04:00:00',
                '17:00'            => '24.11.2006 17:00:00');

compare(\%simple);
compare(\%complex);
compare(\%specific);

sub compare {
    my $href = shift;
    foreach my $key (sort keys %$href) {
        compare_strings($key, $href->{$key});
    }
}

sub compare_strings {
    my ($string, $result) = @_;

    my $parse = DateTime::Format::Natural->new(lang => 'de');
    $parse->_set_datetime($year, $month, $day, $hour, $min, $sec);

    my $dt = $parse->parse_datetime(string => $string);

    my $res_string = sprintf("%02s.%02s.%4s %02s:%02s:%02s", $dt->day, $dt->month, $dt->year, $dt->hour, $dt->min, $dt->sec);
    is($res_string, $result, $string);
}
