#!/usr/bin/perl

use strict;
use warnings;

use Math::Factor::XS ':all';
use Test::More tests => 2;

my $number = 348226;
my @factors = factors($number);
my @matches = matches($number, @factors);

is($factors[2], 314, 'factors()');
is($matches[1][1], 2218, 'matches()');
