#!/usr/bin/perl

use strict;
use warnings;

use DateTime::Format::Natural;
use DateTime::Format::Natural::Test;
use Test::More;

my @specific = (
    { '27/5/1979'              => [ '27.05.1979 00:00:00', 'dd/m/yyyy'  ] },
    { '5/27/1979'              => [ '27.05.1979 00:00:00', 'mm/d/yyyy'  ] },
    { '05/27/79'               => [ '27.05.2079 00:00:00', 'mm/dd/yy'   ] },
    { '1979-05-27'             => [ '27.05.1979 00:00:00', 'yyyy-mm-dd' ] },
    { '1979-05-27 21:09:14'    => [ '27.05.1979 21:09:14', 'yyyy-mm-dd' ] },
    { '31.12.99'               => [ '31.12.2099 00:00:00', undef        ] },
    { '31-12-99'               => [ '31.12.2099 00:00:00', undef        ] },
    { '1/3'                    => [ '03.01.2006 00:00:00', undef        ] },
    { '1/3 16:00'              => [ '03.01.2006 16:00:00', undef        ] },
    { '12/03/2008 06:56:06 am' => [ '12.03.2008 06:56:06', undef        ] },
    { '12/03/2008 06:56:06 pm' => [ '12.03.2008 18:56:06', undef        ] },
);

_run_tests(11, [ [ \@specific ] ], \&compare);

sub compare
{
    my $aref = shift;

    foreach my $href (@$aref) {
        my $key = (keys %$href)[0];
        my @formats = do {
            local $_ = $href->{$key}->[1];
            defined ($_) ? $case_strings->($_) : (undef) x 3;
        };
        foreach my $format (@formats) {
            compare_strings($key, $href->{$key}->[0], $format);
        }
    }
}

sub compare_strings
{
    my ($string, $result, $format) = @_;

    my %args = defined $format ? (format => $format) : ();

    my $parser = DateTime::Format::Natural->new(%args);
    $parser->_set_datetime(\%time);

    my $dt = $parser->parse_datetime($string);

    if ($parser->success) {
        is(_result_string($dt), $result, _message($string));
    }
    else {
        fail(_message($string));
    }
}
