#!/usr/bin/perl

use strict;
use warnings;
use boolean qw(true);

use Test::MockTime qw(set_fixed_time);
use DateTime::Format::Natural;
use DateTime::Format::Natural::Test;
use Test::More;

my $date = join '.', map $time{$_}, qw(day month year);
my $time = join ':', map $time{$_}, qw(hour minute second);

set_fixed_time(
    "$date $time",
    '%d.%m.%Y %H:%M:%S',
);

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
    { '4th february'       => '04.02.2007 00:00:00' },
    { 'november 3rd'       => '03.11.2007 00:00:00' },
    { 'sunday 11:00'       => '26.11.2006 11:00:00' },
    { 'monday at 8'        => '27.11.2006 08:00:00' },
    { 'tuesday at 8pm'     => '28.11.2006 20:00:00' },
    { 'wednesday at 4pm'   => '29.11.2006 16:00:00' },
    { 'friday 03:00 am'    => '24.11.2006 03:00:00' },
    { 'friday 03:00 pm'    => '24.11.2006 15:00:00' },
    { 'monday at 03:00 am' => '27.11.2006 03:00:00' },
    { 'monday at 03:00 pm' => '27.11.2006 15:00:00' },
);

my @formatted = (
    { '1/3'   => '03.01.2007 00:00:00' },
    { '12/24' => '24.12.2006 00:00:00' },
);

_run_tests(28, [ [ \@simple ], [ \@combined ], [ \@formatted ] ], \&compare);

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

    if ($parser->success) {
        is(_result_string($dt), $result, _message($string));
    }
    else {
        fail(_message($string));
    }
}
