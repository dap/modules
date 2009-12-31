#!/usr/bin/perl

use strict;
use warnings;

use DateTime::Format::Natural;
use Test::More tests => 5;

my $parser = DateTime::Format::Natural->new;
my $stringify = sub { local $" = "\n"; "@_\n" };

{
    my $string;

    $string = 'now';
    $parser->parse_datetime($string);
    is($stringify->(($parser->trace)[0]), <<'EOT', $string);
DateTime::Format::Natural::Base::_no_op
EOT
    $string = 'yesterday 3 years ago';
    $parser->parse_datetime($string);
    is($stringify->(($parser->trace)[0]), <<'EOT', $string);
DateTime::Format::Natural::Base::_unit_variant
DateTime::Format::Natural::Base::_ago_variant
day: 1
year: 1
EOT
    $string = 'monday to friday';
    $parser->parse_datetime_duration($string);
    is($stringify->($parser->trace), <<'EOT', $string);
DateTime::Format::Natural::Base::_weekday
day: 1
DateTime::Format::Natural::Base::_weekday
day: 1
EOT
}

{
    my ($string, @trace);

    $string = 'bogus';
    $parser->parse_datetime($string);
    @trace = $parser->trace;
    ok(!@trace, 'empty trace for parse_datetime');

    $string = 'bogus to bogus';
    $parser->parse_datetime_duration($string);
    @trace = $parser->trace;
    ok(!@trace, 'empty trace for parse_datetime_duration');
}
