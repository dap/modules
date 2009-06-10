#!/usr/bin/perl

use strict;
use warnings;
use boolean qw(true);

use DateTime::Format::Natural;
use Test::More;

my ($sec, $min, $hour, $day, $month, $year) = (8, 13, 1, 24, 11, 2006);

my @simple = (
    { 'now' => '24.11.2006 01:13:08' },
);

{
    my $tests = 1;

    local $@;

    if (eval "require Date::Calc") {
        plan tests => $tests * 2;
        compare(\@simple);
    }
    else {
        plan tests => $tests;
    }

    $DateTime::Format::Natural::Compat::Pure = true;

    compare(\@simple);
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

    my $parser = DateTime::Format::Natural->new(
        datetime => DateTime->new(
            year   => $year,
            month  => $month,
            day    => $day,
            hour   => $hour,
            minute => $min,
            second => $sec,
        ),
    );
    my $dt = $parser->parse_datetime($string);

    my $res_string = sprintf('%02d.%02d.%4d %02d:%02d:%02d', $dt->day, $dt->month, $dt->year, $dt->hour, $dt->min, $dt->sec);

    if ($parser->success) {
        is($res_string, $result, $string);
    }
    else {
        fail($string);
    }
}
