#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;

BEGIN {
    use_ok('LUGS::Events::Parser');
}

diag("Testing LUGS::Events::Parser $LUGS::Events::Parser::VERSION, Perl $], $^X");
