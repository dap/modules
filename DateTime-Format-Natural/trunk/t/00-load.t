#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 10;

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
        DateTime::Format::Natural::Utils
        DateTime::Format::Natural::Wrappers
    );
    use_ok($_) foreach @modules;
}
