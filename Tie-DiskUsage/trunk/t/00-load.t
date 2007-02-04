#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;

BEGIN {
    use_ok('Tie::DiskUsage');
}

diag("Testing Tie::DiskUsage $Tie::DiskUsage::VERSION, Perl $], $^X");
