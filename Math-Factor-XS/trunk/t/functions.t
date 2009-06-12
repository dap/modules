#!/usr/bin/perl

use strict;
use warnings;
use boolean qw(true);

use Math::Factor::XS ':all';
use Test::More tests => 5;

my $number = 30107;

my @factors = factors($number);
my @matches = matches($number, \@factors);

is(scalar @factors, 14, 'factors() - count of elements');
is($factors[2], 17, 'factors() - numbers returned');
is(scalar @matches, 7, 'matches() - count of elements');
is($matches[1][1], 2737, 'matches() - numbers returned');

@matches = matches($number, \@factors, { skip_multiples => true });
is(scalar @matches, 4, "matches() - count of elements with 'skip_multiples' set");
