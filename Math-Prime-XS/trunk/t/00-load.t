#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;

BEGIN {
	use_ok('Math::Prime::XS');
}

diag("Testing Math::Prime::XS $Math::Prime::XS::VERSION, Perl $], $^X");
