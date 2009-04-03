#!/usr/bin/perl

use strict;
use warnings;
use boolean qw(true);

use Test::MockTime qw(set_fixed_time);
use DateTime::Format::Natural;
use Test::More;

my ($sec, $min, $hour, $day, $month, $year) = (00, 13, 01, 24, 11, 2006);
set_fixed_time("$day.$month.$year $hour:$min:$sec", '%d.%m.%Y %H:%M:%S');

my @prefer_future = (
    { 'friday'       => '24.11.2006 01:13:00' },
    { 'monday'       => '27.11.2006 01:13:00' },
    { 'november'     => '24.11.2006 01:13:00' },
    { 'january'      => '24.01.2007 01:13:00' },
    { 'last january' => '24.01.2005 01:13:00' },
    { 'next january' => '24.01.2007 01:13:00' },
    { 'next friday'  => '01.12.2006 01:13:00' },
    { 'last friday'  => '17.11.2006 01:13:00' },
    { '00:00'        => '25.11.2006 00:00:00' },
    { '0am'          => '25.11.2006 00:00:00' },
);

{
    my $tests = 10;

    local $@;

    if (eval "require Date::Calc") {
        plan tests => $tests * 2;
        compare(\@prefer_future);
    }
    else {
        plan tests => $tests;
    }

    $DateTime::Format::Natural::Compat::Pure = true;

    compare(\@prefer_future);
}

sub compare
{
    my $aref = shift;
    foreach my $href (@$aref) {
        my $key = (keys %$href)[0];
        compare_strings($key, $href->{$key});
    }
}

sub compare_strings
{
    my ($string, $result) = @_;

    my $parser = DateTime::Format::Natural->new(prefer_future => true);
    my $dt = $parser->parse_datetime($string);

    my $res_string = sprintf('%02d.%02d.%4d %02d:%02d:%02d', $dt->day, $dt->month, $dt->year, $dt->hour, $dt->min, $dt->sec);

    if ($parser->success) {
        is($res_string, $result, $string);
    }
    else {
        fail($string);
    }
}
