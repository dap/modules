#!/usr/bin/perl

use strict;
use warnings;

use DateTime::Format::Natural;
use Test::More tests => 3;

my ($sec, $min, $hour, $day, $month, $year) = (00, 13, 01, 24, 11, 2006);

my %specific = ('27/5/1979'  => [ '27.05.1979 01:13:00', 'dd/m/yyyy'  ],
                '05/27/79'   => [ '27.05.1979 01:13:00', 'mm/dd/yy'   ],
                '1979-05-27' => [ '27.05.1979 01:13:00', 'yyyy-mm-dd' ]);

compare(\%specific);

sub compare 
{
    my $href = shift;
    foreach my $key (sort keys %$href) {
        compare_strings($key, $href->{$key}->[0], $href->{$key}->[1]);
    }
}

sub compare_strings 
{
    my ($string, $result, $format) = @_;

    my $parse = DateTime::Format::Natural->new(format => $format);
    $parse->_set_datetime($year, $month, $day, $hour, $min, $sec);

    my $dt = $parse->parse_datetime(string => $string);

    my $res_string = sprintf("%02d.%02d.%4d %02d:%02d:%02d", $dt->day, $dt->month, $dt->year, $dt->hour, $dt->min, $dt->sec);
    is($res_string, $result, $string);
}
