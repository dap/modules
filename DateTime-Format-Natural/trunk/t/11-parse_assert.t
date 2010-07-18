#!/usr/bin/perl

use strict;
use warnings;

use DateTime::Format::Natural;
use Test::More tests => 1;

{
    # Assert for prefixed dates that an extracted unit which is
    # partially invalid is not being passed to a DateTime wrapper.
    local $@;
    eval {
        my $parser = DateTime::Format::Natural->new;
        $parser->parse_datetime('+1XXXday');
        $parser->parse_datetime('-1dayXXX');
    };
    ok(!$@, 'prefixed date');
}
