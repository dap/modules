#!/usr/bin/perl

use strict;
use warnings;

use FindBin qw($Bin);
use Test::More tests => 2;
use Tie::DiskUsage;

my $path = File::Spec->catfile($Bin, 'data', 'tie.t.in');

tie my %usage, 'Tie::DiskUsage', $path;
is($usage{$path}, 48, 'basic tie (default du location)');
untie %usage;

# let File::Which figure out where du is located
$Tie::DiskUsage::DU_BIN = '/invalid/path/to/du';

local $@;
eval { tie %usage, 'Tie::DiskUsage', $path };
is($@, '', 'basic tie (gather du location)');
untie %usage;
