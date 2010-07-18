#!/usr/bin/perl

use strict;
use warnings;

use DateTime::Format::Natural;
use Test::More tests => 8;

my @ordinal_number = (
    '2d aug',
    '3d aug',
    '11th sep',
    '12th sep',
    '13th sep',
    '21st oct',
    '22nd oct',
    '23rd oct',
);

check(\@ordinal_number);

sub check
{
    my $aref = shift;
    foreach my $string (@$aref) {
        check_success($string);
    }
}

sub check_success
{
    my ($string) = @_;

    my $parser = DateTime::Format::Natural->new;
    $parser->parse_datetime($string);

    if ($parser->success) {
        pass($string);
    }
    else {
        fail($string);
    }
}
