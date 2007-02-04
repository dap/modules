#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;

BEGIN {
	use_ok('Config::Inetd');
}

diag("Testing Config::Inetd $Config::Inetd::VERSION, Perl $], $^X");
