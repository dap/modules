#!/usr/bin/perl

use strict;
use warnings;

use Test::MockTime qw(set_fixed_time);
use DateTime::Format::Natural;
use Test::More tests => 1;

{
    local $@;
    eval {
        set_fixed_time('31.03.2009 04:32:22', '%d.%m.%Y %H:%M:%S');
        DateTime::Format::Natural->new->parse_datetime('april 3');
    };
    ok(!$@, 'units set at once');
}
