#!/usr/bin/perl

use strict;
use warnings;

use DateTime::Format::Natural;
use Test::More tests => 46;

my @must_fail = (
    '1 seconds ago',
    '1 minutes ago',
    '1 hours ago',
    '1 days ago',
    '1 weeks ago',
    '1 months ago',
    '1 years ago',
    'tomorrow 1 seconds ago',
    'tomorrow 1 minutes ago',
    'tomorrow 1 hours ago',
    'tomorrow 1 days ago',
    'tomorrow 1 weeks ago',
    'tomorrow 1 months ago',
    'tomorrow 1 years ago',
    'yesterday 1 seconds ago',
    'yesterday 1 minutes ago',
    'yesterday 1 hours ago',
    'yesterday 1 days ago',
    'yesterday 1 weeks ago',
    'yesterday 1 months ago',
    'yesterday 1 years ago',
    'fri 1 months ago at 5am',
    'wednesday 1 months ago at 8pm',
    '1 minutes before now',
    '1 minutes from now',
    '1 hours from now',
    '1 hours before now',
    '1 days before now',
    '1 days from now',
    '1 weeks before now',
    '1 weeks from now',
    '1 months before now',
    '1 months from now',
    '1 years before now',
    '1 years from now',
    'in 1 minutes',
    'in 1 hours',
    'in 1 days',
    '1 hours before tomorrow',
    '1 hours before yesterday',
    '1 hours after tomorrow',
    '1 hours after yesterday',
    '1 hours before noon',
    '1 hours after noon',
    '1 hours before midnight',
    '1 hours after midnight',
);

check(\@must_fail);

sub check
{
    my $aref = shift;
    foreach my $string (@$aref) {
        check_fail($string);
    }
}

sub check_fail
{
    my ($string) = @_;

    my $parser = DateTime::Format::Natural->new;
    $parser->parse_datetime($string);

    if (!$parser->success) {
        pass($string);
    }
    else {
        fail($string);
    }
}
