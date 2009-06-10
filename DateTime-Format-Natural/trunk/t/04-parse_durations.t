#!/usr/bin/perl

use strict;
use warnings;
use boolean qw(true);

use DateTime::Format::Natural;
use Test::More;

my ($sec, $min, $hour, $day, $month, $year) = (8, 13, 1, 24, 11, 2006);

my @absolute = (
    { 'monday to friday' => [ '20.11.2006 00:00:00', '24.11.2006 00:00:00' ] },
    { 'march to august'  => [ '01.03.2006 00:00:00', '01.08.2006 00:00:00' ] },
    { '1999 to 2006'     => [ '01.01.1999 00:00:00', '01.01.2006 00:00:00' ] },
);

my @relative = (
    { '2009-03-10 9:00 to 11:00' => [ '10.03.2009 09:00:00', '10.03.2009 11:00:00' ] },
    { 'for 4 seconds'            => [ '24.11.2006 01:13:08', '24.11.2006 01:13:12' ] },
    { 'for 4 minutes'            => [ '24.11.2006 01:13:08', '24.11.2006 01:17:08' ] },
    { 'for 4 hours'              => [ '24.11.2006 01:13:08', '24.11.2006 05:13:08' ] },
    { 'for 4 days'               => [ '24.11.2006 01:13:08', '28.11.2006 01:13:08' ] },
    { 'for 4 weeks'              => [ '24.11.2006 01:13:08', '22.12.2006 01:13:08' ] },
    { 'for 4 months'             => [ '24.11.2006 01:13:08', '24.03.2007 01:13:08' ] },
    { 'for 4 years'              => [ '24.11.2006 01:13:08', '24.11.2010 01:13:08' ] },
);

{
    my $tests = 11;

    local $@;

    if (eval "require Date::Calc") {
        plan tests => $tests * 2;
        compare(\@absolute);
        compare(\@relative);
    }
    else {
        plan tests => $tests;
    }

    $DateTime::Format::Natural::Compat::Pure = true;

    compare(\@absolute);
    compare(\@relative);
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

    my $parser = DateTime::Format::Natural->new;
    $parser->_set_datetime($year, $month, $day, $hour, $min, $sec);

    my @dt = $parser->parse_datetime_duration($string);

    my $pass = true;
    foreach my $i (0..$#dt) {
        my $res_string = sprintf('%02d.%02d.%4d %02d:%02d:%02d', $dt[$i]->day, $dt[$i]->month, $dt[$i]->year, $dt[$i]->hour, $dt[$i]->min, $dt[$i]->sec);
        $pass &= $res_string eq $result->[$i];
    }

    if ($parser->success && $pass && scalar @dt == 2) {
        ok($pass, $string);
    }
    else {
        fail($string);
    }
}
