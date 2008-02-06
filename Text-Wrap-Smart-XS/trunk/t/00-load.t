#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;

BEGIN {
    use_ok('Text::Wrap::Smart::XS');
}

diag("Testing Text::Wrap::Smart::XS $Text::Wrap::Smart::XS::VERSION, Perl $], $^X");
