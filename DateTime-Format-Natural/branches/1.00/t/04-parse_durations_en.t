#!/usr/bin/perl

use strict;
use warnings;

use DateTime::Format::Natural;
use Test::More tests => 3;

my ($sec, $min, $hour, $day, $month, $year) = (00, 13, 01, 24, 11, 2006);

my %durations = ('monday to friday' => [ '20.11.2006 01:13:00', '24.11.2006 01:13:00' ],
                 'march to august'  => [ '24.03.2006 01:13:00', '24.08.2006 01:13:00' ],
                 '1999 to 2006'     => [ '24.11.1999 01:13:00', '24.11.2006 01:13:00' ]);

compare(\%durations);

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

    my $parse = DateTime::Format::Natural->new(lang => 'en');
    $parse->_set_datetime($year, $month, $day, $hour, $min, $sec);

    my @dt = $parse->parse_datetime_duration(string => $string);

    my $passed = 1;
    foreach my $i (0..$#dt) {
        my $res_string = sprintf("%02d.%02d.%4d %02d:%02d:%02d", $dt[$i]->day, $dt[$i]->month, $dt[$i]->year, $dt[$i]->hour, $dt[$i]->min, $dt[$i]->sec);
        $passed &= $res_string eq $result->[$i];
    }

    if ($parse->success && $passed && @dt == 2) {
        ok($passed, $string);
    }
    else {
        fail($string);
    }
}
