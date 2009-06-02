#!/usr/bin/perl

use strict;
use warnings;
use boolean qw(true);

use DateTime::Format::Natural;
use Test::More;

my ($sec, $min, $hour, $day, $month, $year) = (8, 13, 1, 24, 11, 2006);

my @specific = (
    { '27/5/1979'           => [ '27.05.1979 00:00:00', 'dd/m/yyyy'  ] },
    { '5/27/1979'           => [ '27.05.1979 00:00:00', 'mm/d/yyyy'  ] },
    { '05/27/79'            => [ '27.05.1979 00:00:00', 'mm/dd/yy'   ] },
    { '1979-05-27'          => [ '27.05.1979 00:00:00', 'yyyy-mm-dd' ] },
    { '1979-05-27 21:09:14' => [ '27.05.1979 21:09:14', 'yyyy-mm-dd' ] },
);

{
    my $tests = 5;

    local $@;

    if (eval "require Date::Calc") {
        plan tests => $tests * 2;
        compare(\@specific);
    }
    else {
        plan tests => $tests;
    }

    $DateTime::Format::Natural::Compat::Pure = true;

    compare(\@specific);
}

sub compare
{
    my $aref = shift;
    foreach my $href (@$aref) {
        my $key = (keys %$href)[0];
        compare_strings($key, $href->{$key}->[0], $href->{$key}->[1]);
    }
}

sub compare_strings
{
    my ($string, $result, $format) = @_;

    my $parser = DateTime::Format::Natural->new(format => $format);
    $parser->_set_datetime($year, $month, $day, $hour, $min, $sec);

    my $dt = $parser->parse_datetime($string);

    my $res_string = sprintf('%02d.%02d.%4d %02d:%02d:%02d', $dt->day, $dt->month, $dt->year, $dt->hour, $dt->min, $dt->sec);

    if ($parser->success) {
        is($res_string, $result, $string);
    }
    else {
        fail($string);
    }
}
