#!/usr/bin/perl

use strict;
use warnings;
use boolean qw(true);

use DateTime::Format::Natural;
use Test::More;

my ($sec, $min, $hour, $day, $month, $year) = (00, 13, 01, 24, 11, 2006);

my @daytime_regular = (
    { 'morning'   => '24.11.2006 08:00:00' },
    { 'afternoon' => '24.11.2006 14:00:00' },
    { 'evening'   => '24.11.2006 20:00:00' },
);

my @daytime_user = (
    { 'morning'   => '24.11.2006 06:00:00' },
    { 'afternoon' => '24.11.2006 13:00:00' },
    { 'evening'   => '24.11.2006 19:00:00' },
);

{
    my $tests = 6;

    local $@;

    my %opts = (
        morning   => 06,
        afternoon => 13,
        evening   => 19,
    );

    if (eval "require Date::Calc") {
        plan tests => $tests * 2;
        compare(\@daytime_regular);
        compare(\@daytime_user, \%opts);
    }
    else {
        plan tests => $tests;
    }

    $DateTime::Format::Natural::Compat::Pure = true;

    compare(\@daytime_regular);
    compare(\@daytime_user, \%opts);
}

sub compare
{
    my ($aref, $opts) = @_;
    foreach my $href (@$aref) {
        my $key = (keys %$href)[0];
        compare_strings($key, $href->{$key}, $opts);
    }
}

sub compare_strings
{
    my ($string, $result, $opts) = @_;

    my $parser = DateTime::Format::Natural->new(daytime => $opts || {});
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
