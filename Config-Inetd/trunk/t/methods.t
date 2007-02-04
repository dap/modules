#!/usr/bin/perl

use strict;
use warnings;

use Config::Inetd;
use Test::More tests => 6;

my ($match, $regex_service, $retval);

my $inetd = Config::Inetd->new('t/inetd.conf');

is($inetd->dump_enabled, 8, '$inetd->dump_enabled()');
is($inetd->dump_disabled, 41, '$inetd->dump_disabled()');
$retval = $inetd->disable(daytime => 'tcp');
is($retval, 1, '$inetd->disable()');
$retval = $inetd->enable(daytime => 'tcp');
is($retval, 1, '$inetd->enable()');
is($inetd->is_enabled(daytime => 'tcp'), 1, '$inetd->is_enabled()');

$regex_service = qr{
                    ^   \#?[\w\Q/.:-[]\E]+ 
                    \s+ (?:stream|dgram) 
                    \s+ (?:tcp|udp|rpc/udp)6? 
		    \s+ (?:no)?wait 
		    \s+ (?:root|_fingerd|_identd) 
		    \s+ (?:/\w+/\w+/[\w\.]+|internal) 
		    \s* (?:[\w\.]+)?
		   }x;

foreach (@{$inetd->{CONF}}) {
    $match++ if /$regex_service/;
}

is($match, 49, '@{$inetd->{CONF}} instance data');
