#!/usr/bin/perl

use strict;
use warnings;

use DateTime::Format::Natural;
use Test::More tests => 41;

my ($sec, $min, $hour, $day, $month, $year) = (00, 13, 01, 24, 11, 2006);

my %simple = ('thursday'             => '23.11.2006 01:13:00',
              'november'             => '24.11.2006 01:13:00',
              'friday 13:00'         => '24.11.2006 13:00:00',
              'mon 2:35'             => '20.11.2006 02:35:00',
              '4pm'                  => '24.11.2006 16:00:00',
              '6 in the morning'     => '24.11.2006 06:00:00',
              'sat 7 in the evening' => '25.11.2006 19:00:00',
              'yesterday'            => '23.11.2006 01:13:00',
              'today'                => '24.11.2006 01:13:00',
              'tomorrow'             => '25.11.2006 01:13:00',
              'this tuesday'         => '21.11.2006 01:13:00',
              'next month'           => '24.12.2006 01:13:00',
              'this morning'         => '24.11.2006 08:00:00',
              'this second'          => '24.11.2006 01:13:00',
              'yesterday at 4:00'    => '23.11.2006 04:00:00',
              'last friday at 20:00' => '17.11.2006 20:00:00',
              'tomorrow at 6:45pm'   => '25.11.2006 18:45:00',
              'afternoon yesterday'  => '23.11.2006 14:00:00',
              'thursday last week'   => '16.11.2006 01:13:00');

my %complex = ('25 seconds ago'                  => '24.11.2006 01:12:35',
               '10 minutes ago'                  => '24.11.2006 01:03:00',
               '3 years ago'                     => '24.11.2003 01:13:00',
               '5 months before now'             => '24.06.2006 01:13:00',
               '7 hours ago'                     => '23.11.2006 18:13:00',
               'in 3 hours'                      => '24.11.2006 04:13:00',
               '1 year ago tomorrow'             => '25.11.2005 01:13:00',
               '3 months ago saturday at 5:00pm' => '26.08.2006 17:00:00',
               '4th day last week'               => '16.11.2006 01:13:00',
               '3rd wednesday in november'       => '15.11.2006 01:13:00',
               '3rd month next year'             => '24.03.2007 01:13:00');

my %specific = ('January 5'         => '05.01.2006 01:13:00',
                'dec 25'            => '25.12.2006 01:13:00',
                'may 27th'          => '27.05.2006 01:13:00',
                'October 2006'      => '24.10.2006 01:13:00',
                'february 14, 2004' => '14.02.2004 01:13:00',
                'Friday'            => '24.11.2006 01:13:00',
                'jan 3 2010'        => '03.01.2010 01:13:00',
                '3 jan 2000'        => '03.01.2000 01:13:00',
                '27/5/1979'         => '27.05.1979 01:13:00',
                '4:00'              => '24.11.2006 04:00:00',
                '17:00'             => '24.11.2006 17:00:00');

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

    my $parse = DateTime::Format::Natural->new(lang => 'en');
    $parse->_set_datetime($year, $month, $day, $hour, $min, $sec);

    my $dt = $parse->parse_datetime(string => $string);

    my $res_string = sprintf("%02s.%02s.%4s %02s:%02s:%02s", $dt->day, $dt->month, $dt->year, $dt->hour, $dt->min, $dt->sec);
    is($res_string, $result, $string);
}
