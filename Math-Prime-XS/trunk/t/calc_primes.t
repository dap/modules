#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 6;
use Math::Prime::XS ':all';

my (@expected_primes, @got_primes);

@expected_primes = qw( 2  3  5  7 11 13 17 19 23 29 31 
                      37 41 43 47 53 59 61 67 71 73 79 
                      83 89 97);

for (0..100) {
    push @got_primes, $_ if is_prime($_);
}

is_deeply(\@got_primes,        \@expected_primes, 'is_prime()'    );
is_deeply([primes(100)],       \@expected_primes, 'primes()',     );
is_deeply([mod_primes(100)],   \@expected_primes, 'mod_primes()'  );
is_deeply([sieve_primes(100)], \@expected_primes, 'sieve_primes()');
is_deeply([sum_primes(100)],   \@expected_primes, 'sum_primes()'  );
is_deeply([trial_primes(100)], \@expected_primes, 'trial_primes()');
