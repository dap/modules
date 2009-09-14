#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 8;

BEGIN
{
    my @modules = qw(
        DateTime::Format::Natural
        DateTime::Format::Natural::Base
        DateTime::Format::Natural::Compat
        DateTime::Format::Natural::Duration
        DateTime::Format::Natural::Helpers
        DateTime::Format::Natural::Lang::Base
        DateTime::Format::Natural::Lang::EN
        DateTime::Format::Natural::Test
    );
    use_ok($_) foreach @modules;
}
