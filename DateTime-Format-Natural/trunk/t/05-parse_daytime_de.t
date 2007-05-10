#!/usr/bin/perl

use strict;
use warnings;

use DateTime::Format::Natural;
use Test::More tests => 3;

my ($sec, $min, $hour, $day, $month, $year) = (00, 13, 01, 24, 11, 2006);

my %daytime = ('Morgen'     => '24.11.2006 06:00:00',
               'Nachmittag' => '24.11.2006 13:00:00',
               'Abend'      => '24.11.2006 19:00:00');

compare(\%daytime);

sub compare {
    my $href = shift;
    foreach my $key (sort keys %$href) {
        compare_strings($key, $href->{$key});
    }
}

sub compare_strings {
    my ($string, $result) = @_;

    my $parse = DateTime::Format::Natural->new(
                lang => 'de',
                daytime => { morning => 06, afternoon => 13, evening => 19 },
    );
    $parse->_set_datetime($year, $month, $day, $hour, $min, $sec);

    my $dt = $parse->parse_datetime(string => $string);

    my $res_string = sprintf("%02s.%02s.%4s %02s:%02s:%02s", $dt->day, $dt->month, $dt->year, $dt->hour, $dt->min, $dt->sec);
    is($res_string, $result, $string);
}
