#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 3;

BEGIN
{
    use_ok('LUGS::Events::Parser');
    use_ok('LUGS::Events::Parser::Event');
    use_ok('LUGS::Events::Parser::Filter');
}
