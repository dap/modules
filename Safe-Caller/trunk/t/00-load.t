#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;

BEGIN {
	use_ok('Safe::Caller');
}

diag("Testing Safe::Caller $Safe::Caller::VERSION, Perl $], $^X");
