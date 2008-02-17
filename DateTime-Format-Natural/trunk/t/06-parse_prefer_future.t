#!/usr/bin/perl

use strict;
use warnings;

use Test::MockTime qw(set_fixed_time);
use DateTime::Format::Natural;
use Test::More tests => 8;

my ($sec, $min, $hour, $day, $month, $year) = (00, 13, 01, 24, 11, 2006);
set_fixed_time("$day.$month.$year $hour:$min:$sec", '%d.%m.%Y %H:%M:%S');

my %prefer_future = ('friday'       => '24.11.2006 01:13:00',
                     'monday'       => '27.11.2006 01:13:00',
                     'november'     => '24.11.2006 01:13:00',
                     'january'      => '24.01.2007 01:13:00',
                     'last january' => '24.01.2005 01:13:00',
                     'next january' => '24.01.2007 01:13:00',
                     'next friday'  => '01.12.2006 01:13:00',
                     'last friday'  => '17.11.2006 01:13:00');

compare(\%prefer_future);

sub compare
{
    my $href = shift;
    foreach my $key (sort keys %$href) {
        compare_strings($key, $href->{$key});
    }
}

sub compare_strings
{
    my ($string, $result) = @_;

    my $parse = DateTime::Format::Natural->new(lang => 'en', prefer_future => 1);
    my $dt = $parse->parse_datetime(string => $string);

    my $res_string = sprintf("%02d.%02d.%4d %02d:%02d:%02d", $dt->day, $dt->month, $dt->year, $dt->hour, $dt->min, $dt->sec);

    if ($parse->success) {
        is($res_string, $result, $string);
    }
    else {
        fail($string);
    }
}
