#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;

BEGIN {
	use_ok('Text::Wrap::Smart');
}

diag("Testing Text::Wrap::Smart $Text::Wrap::Smart::VERSION, Perl $], $^X");
