#!/usr/bin/perl

use strict;
use warnings;

use DateTime::Format::Natural;
use DateTime::Format::Natural::Test;
use Test::More;

my @specific = (
    { '27/5/1979'           => [ '27.05.1979 00:00:00', 'dd/m/yyyy'  ] },
    { '5/27/1979'           => [ '27.05.1979 00:00:00', 'mm/d/yyyy'  ] },
    { '05/27/79'            => [ '27.05.2079 00:00:00', 'mm/dd/yy'   ] },
    { '1979-05-27'          => [ '27.05.1979 00:00:00', 'yyyy-mm-dd' ] },
    { '1979-05-27 21:09:14' => [ '27.05.1979 21:09:14', 'yyyy-mm-dd' ] },
);

_run_tests(5, [ [ \@specific ] ], \&compare);

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
    $parser->_set_datetime(\%time);

    my $dt = $parser->parse_datetime($string);

    my $res_string = sprintf('%02d.%02d.%4d %02d:%02d:%02d', $dt->day, $dt->month, $dt->year, $dt->hour, $dt->min, $dt->sec);

    if ($parser->success) {
        is($res_string, $result, _message($string));
    }
    else {
        fail(_message($string));
    }
}
