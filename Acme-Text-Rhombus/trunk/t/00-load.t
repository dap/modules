#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;

BEGIN {
	use_ok('Acme::Text::Rhombus');
}

diag("Testing Acme::Text::Rhombus $Acme::Text::Rhombus::VERSION, Perl $], $^X");
