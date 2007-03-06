#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;

BEGIN {
	use_ok('Hook::Output::File');
}

diag("Testing Hook::Output::File $Hook::Output::File::VERSION, Perl $], $^X");
