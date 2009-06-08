#!/usr/bin/perl

use strict;
use warnings;
use boolean qw(true);

use Test::MockTime qw(set_fixed_time);
use DateTime::Format::Natural;
use Test::More;

my ($sec, $min, $hour, $day, $month, $year) = (8, 13, 1, 24, 11, 2006);
set_fixed_time("$day.$month.$year $hour:$min:$sec", '%d.%m.%Y %H:%M:%S');

my @simple = (
    { 'friday'       => '24.11.2006 00:00:00' },
    { 'monday'       => '27.11.2006 00:00:00' },
    { 'november'     => '01.11.2007 00:00:00' },
    { 'january'      => '01.01.2007 00:00:00' },
    { 'last january' => '01.01.2005 00:00:00' },
    { 'next january' => '01.01.2007 00:00:00' },
    { 'next friday'  => '01.12.2006 00:00:00' },
    { 'last friday'  => '17.11.2006 00:00:00' },
    { '00:30:15'     => '25.11.2006 00:30:15' },
    { '00:00'        => '25.11.2006 00:00:00' },
    { '0 am'         => '25.11.2006 00:00:00' },
    { '0am'          => '25.11.2006 00:00:00' },
    { '0:30am'       => '25.11.2006 00:30:00' },
    { '8 pm'         => '24.11.2006 20:00:00' },
    { '4pm'          => '24.11.2006 16:00:00' },
    { '4:20pm'       => '24.11.2006 16:20:00' },
);

my @combined = (
    { '4th february'     => '04.02.2007 00:00:00' },
    { 'november 3rd'     => '03.11.2007 00:00:00' },
    { 'sunday 11:00'     => '26.11.2006 11:00:00' },
    { 'monday at 8'      => '27.11.2006 08:00:00' },
    { 'tuesday at 8pm'   => '28.11.2006 20:00:00' },
    { 'wednesday at 4pm' => '29.11.2006 16:00:00' },
);

{
    my $tests = 22;

    local $@;

    if (eval "require Date::Calc") {
        plan tests => $tests * 2;
        compare(\@simple);
        compare(\@combined);
    }
    else {
        plan tests => $tests;
    }

    $DateTime::Format::Natural::Compat::Pure = true;

    compare(\@simple);
    compare(\@combined);
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
