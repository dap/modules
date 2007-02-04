#!/usr/bin/perl

use strict;
use warnings;

use DateTime::Format::Natural;
use Test::More tests => 38;

my ($min, $hour, $day, $month, $year) = (13,01,24,11,2006);

my %simple = ('Donnerstag'               => '23.11.2006 01:13',
              'November'                 => '24.11.2006 01:13',
              'Freitag 13:00'            => '24.11.2006 13:00',
              'Mon 2:35'                 => '20.11.2006 02:35',
              '4pm'                      => '24.11.2006 16:00',
              '6 am Morgen'              => '24.11.2006 06:00',
              'Samstag 7 am Abend'       => '25.11.2006 19:00',
              'Gestern'                  => '23.11.2006 01:13',
              'Heute'                    => '24.11.2006 01:13',
              'Morgen'                   => '25.11.2006 01:13',
              'Diesen Dienstag'          => '21.11.2006 01:13',
              'Nächster Monat'           => '24.12.2006 01:13',
              'Morgen'                   => '24.11.2006 08:00',
              'Sekunde'                  => '24.11.2006 01:13',
              'Gestern um 4:00'          => '23.11.2006 04:00',
              'Letzten Freitag um 20:00' => '17.11.2006 20:00',
              'morgen um 6:45pm'         => '25.11.2006 18:45',
              'Gestern nachmittag'       => '23.11.2006 12:00',
              'Donnerstag letzte Woche'  => '16.11.2006 01:13');

my %complex = ('3 Jahre her'                     => '24.11.2003 01:13',
               '5 Monate vor jetzt'              => '24.06.2006 01:13',
               '7 Stunden her'                   => '23.11.2006 18:13',
               'in 3 Stunden'                    => '24.11.2006 04:13',
               'morgen 1 Jahr her'               => '25.11.2005 01:13',
               'Samstag 3 Tage her um 5:00pm'    => '22.11.2006 17:00',
               '4 Tag letzte Woche'              => '16.11.2006 01:13',
               '3 Mittwoch in November'          => '15.11.2006 01:13',
               '3 Monat nächstes Jahr'           => '24.03.2007 01:13');

my %specific = ('Januar 5'          => '05.01.2006 01:13',
                'dez 25'            => '25.12.2006 01:13',
                'mai 27'            => '27.05.2006 01:13',
                'Oktober 2006'      => '24.10.2006 01:13',
                'Februar 14, 2004'  => '14.02.2004 01:13',
                'Freitag'           => '24.11.2006 01:13',
                'jan 3 2010'        => '03.01.2010 01:13',
                '3 jan 2000'        => '03.01.2000 01:13',
                '27/5/1979'         => '27.05.1979 01:13',
                '4:00'              => '24.11.2006 04:00',
                '17:00'             => '24.11.2006 17:00');

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
    $parse->_set_datetime($year, $month, $day, $hour, $min);

    my $dt = $parse->parse_datetime(string => $string);
    my $res_string = sprintf("%02s.%02s.%4s %02s:%02s", $dt->day, $dt->month, $dt->year, $dt->hour, $dt->min);

    is($res_string, $result, $string);
}
