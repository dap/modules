#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 6;

BEGIN
{
    use_ok('DateTime::Format::Natural');
    use_ok('DateTime::Format::Natural::Base');
    use_ok('DateTime::Format::Natural::Compat');
    use_ok('DateTime::Format::Natural::Helpers');
    use_ok('DateTime::Format::Natural::Lang::Base');
    use_ok('DateTime::Format::Natural::Lang::EN');
}
