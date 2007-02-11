#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;

BEGIN {
	use_ok('Number::Continuation');
}

diag("Testing Number::Continuation $Number::Continuation::VERSION, Perl $], $^X");
