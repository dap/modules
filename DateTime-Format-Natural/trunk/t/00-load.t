#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 5;

BEGIN {
	use_ok('DateTime::Format::Natural');
	use_ok('DateTime::Format::Natural::Base');
	use_ok('DateTime::Format::Natural::Lang::Base');
	use_ok('DateTime::Format::Natural::Lang::DE');
	use_ok('DateTime::Format::Natural::Lang::EN');
}
