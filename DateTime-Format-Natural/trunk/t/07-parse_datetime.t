#!/usr/bin/perl

use strict;
use warnings;

use DateTime::Format::Natural;
use DateTime::Format::Natural::Test;
use Test::More;

my @simple = (
    { 'now' => '24.11.2006 01:13:08' },
);

_run_tests(1, [ [ \@simple ] ], \&compare);

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

    my $parser = DateTime::Format::Natural->new(datetime => DateTime->new(%time));
    my $dt = $parser->parse_datetime($string);

    my $res_string = sprintf('%02d.%02d.%4d %02d:%02d:%02d', $dt->day, $dt->month, $dt->year, $dt->hour, $dt->min, $dt->sec);

    if ($parser->success) {
        is($res_string, $result, _message($string));
    }
    else {
        fail(_message($string));
    }
}
