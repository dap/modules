#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;

BEGIN {
    use_ok('LaTeX::TOM');
}

diag("Testing LaTeX::TOM $LaTeX::TOM::VERSION, Perl $], $^X");
