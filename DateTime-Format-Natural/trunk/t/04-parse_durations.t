#!/usr/bin/perl

use strict;
use warnings;
use boolean qw(true);

use DateTime::Format::Natural;
use DateTime::Format::Natural::Test;
use Test::More;

my @absolute = (
    { 'monday to friday' => [ '20.11.2006 00:00:00', '24.11.2006 00:00:00' ] },
    { 'march to august'  => [ '01.03.2006 00:00:00', '01.08.2006 00:00:00' ] },
    { '1999 to 2006'     => [ '01.01.1999 00:00:00', '01.01.2006 00:00:00' ] },
);

my @combined = (
    { 'first day of 2009 to last day of 2009' => [ '01.01.2009 00:00:00', '31.12.2009 00:00:00' ] },
    { 'first day of may to last day of may'   => [ '01.05.2006 00:00:00', '31.05.2006 00:00:00' ] },
    { 'first to last day of 2008'             => [ '01.01.2008 00:00:00', '31.12.2008 00:00:00' ] },
    { 'first to last day of september'        => [ '01.09.2006 00:00:00', '30.09.2006 00:00:00' ] },
);

my @relative = (
    { '1999-12-31 to tomorrow'   => [ '31.12.1999 00:00:00', '25.11.2006 00:00:00' ] },
    { 'now to 2010-01-01'        => [ '24.11.2006 01:13:08', '01.01.2010 00:00:00' ] },
    { '2009-03-10 9:00 to 11:00' => [ '10.03.2009 09:00:00', '10.03.2009 11:00:00' ] },
    { '1/3 to 2/3'               => [ '03.01.2006 00:00:00', '03.02.2006 00:00:00' ] },
    { '2/3 to in 1 week'         => [ '03.02.2006 00:00:00', '01.12.2006 01:13:08' ] },
    { '3/3 21:00 to in 5 days'   => [ '03.03.2006 21:00:00', '29.11.2006 01:13:08' ] },
    { 'for 4 seconds'            => [ '24.11.2006 01:13:08', '24.11.2006 01:13:12' ] },
    { 'for 4 minutes'            => [ '24.11.2006 01:13:08', '24.11.2006 01:17:08' ] },
    { 'for 4 hours'              => [ '24.11.2006 01:13:08', '24.11.2006 05:13:08' ] },
    { 'for 4 days'               => [ '24.11.2006 01:13:08', '28.11.2006 01:13:08' ] },
    { 'for 4 weeks'              => [ '24.11.2006 01:13:08', '22.12.2006 01:13:08' ] },
    { 'for 4 months'             => [ '24.11.2006 01:13:08', '24.03.2007 01:13:08' ] },
    { 'for 4 years'              => [ '24.11.2006 01:13:08', '24.11.2010 01:13:08' ] },
);

_run_tests(20, [ [ \@absolute ], [ \@combined ], [ \@relative ] ], \&compare);

sub compare
{
    my $aref = shift;

    foreach my $href (@$aref) {
        my $key = (keys %$href)[0];
        foreach my $string ($case_strings->($key)) {
            compare_strings($string, $href->{$key});
        }
    }
}

sub compare_strings
{
    my ($string, $result) = @_;

    my $parser = DateTime::Format::Natural->new;
    $parser->_set_datetime(\%time);

    my @dt = $parser->parse_datetime_duration($string);

    my $pass = true;
    foreach my $i (0..$#dt) {
        $pass &= _result_string($dt[$i]) eq $result->[$i];
    }

    if ($parser->success && $pass && @dt == 2) {
        ok($pass, _message($string));
    }
    else {
        fail(_message($string));
    }
}
