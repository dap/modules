#!/usr/bin/perl

use strict;
use warnings;

use File::Spec;
use File::Which qw(which);
use FindBin qw($Bin);
use Test::More tests => 2;
use Tie::DiskUsage;

BAIL_OUT('unsupported OS') unless which('du');

my $path = File::Spec->catfile($Bin, 'data');

tie my %usage, 'Tie::DiskUsage', $path;
cmp_ok($usage{$path}, '>', 0, 'basic tie (default du location)');
untie %usage;

# let File::Which figure out where du is located
$Tie::DiskUsage::DU_BIN = '/invalid/path/to/du';

local $@;
eval { tie %usage, 'Tie::DiskUsage', $path };
is($@, '', 'basic tie (gather du location)');
untie %usage;
