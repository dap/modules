#!/usr/bin/perl

use strict;
use warnings;

use Config::Inetd;
use File::Spec;
use FindBin qw($Bin);
use Test::More tests => 6;

if (!-e $Config::Inetd::INETD_CONF) {
    BAIL_OUT('no system-wide inetd.conf found');
}

my $inetd = Config::Inetd->new(File::Spec->catfile($Bin, 'data/inetd.conf'));

is($inetd->dump_enabled, 8, '$inetd->dump_enabled()');
is($inetd->dump_disabled, 41, '$inetd->dump_disabled()');
is($inetd->disable(daytime => 'tcp'), 1, '$inetd->disable()');
is($inetd->enable(daytime => 'tcp'), 1, '$inetd->enable()');
is($inetd->is_enabled(daytime => 'tcp'), 1, '$inetd->is_enabled()');

my $regex_service = qr{
    ^   \#?[\w\Q/.:-[]\E]+ 
    \s+ (?:stream|dgram) 
    \s+ (?:tcp|udp|rpc/udp)6? 
    \s+ (?:no)?wait 
    \s+ (?:root|_fingerd|_identd) 
    \s+ (?:/\w+/\w+/[\w\.]+|internal) 
    \s* (?:[\w\.]+)?
}x;

my $match;
foreach (@{$inetd->{CONF}}) {
    $match++ if /$regex_service/;
}

is($match, 49, '@{$inetd->{CONF}} instance data');
