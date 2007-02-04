#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;

BEGIN {
	use_ok('Math::Factor::XS');
}

diag("Testing Math::Factor::XS $Math::Factor::XS::VERSION, Perl $], $^X");
