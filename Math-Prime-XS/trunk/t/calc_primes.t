#!/usr/bin/perl

use strict;
use warnings;

use Math::Prime::XS ':all';
use Test::More tests => 11;

my @got_primes;
foreach my $num (0..100) {
    push @got_primes, $num if is_prime($num);
}

my @expected_all_primes = (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31,
                           37, 41, 43, 47, 53, 59, 61, 67, 71, 73,
                           79, 83, 89, 97);

is_deeply(\@got_primes,        \@expected_all_primes, 'is_prime()');

is_deeply([primes(100)],       \@expected_all_primes, 'primes() (all)',     );
is_deeply([mod_primes(100)],   \@expected_all_primes, 'mod_primes() (all)'  );
is_deeply([sieve_primes(100)], \@expected_all_primes, 'sieve_primes() (all)');
is_deeply([sum_primes(100)],   \@expected_all_primes, 'sum_primes() (all)'  );
is_deeply([trial_primes(100)], \@expected_all_primes, 'trial_primes() (all)');

my @expected_range_primes = (31, 37, 41, 43, 47, 53, 59, 61, 67);

is_deeply([primes(30,70)],       \@expected_range_primes, 'primes() (range)'      );
is_deeply([mod_primes(30,70)],   \@expected_range_primes, 'mod_primes() (range)'  );
is_deeply([sieve_primes(30,70)], \@expected_range_primes, 'sieve_primes() (range)');
is_deeply([sum_primes(30,70)],   \@expected_range_primes, 'sum_primes() (range)'  );
is_deeply([trial_primes(30,70)], \@expected_range_primes, 'trial_primes() (range)');
