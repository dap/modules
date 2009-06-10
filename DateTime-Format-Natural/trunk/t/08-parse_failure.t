#!/usr/bin/perl

use strict;
use warnings;

use DateTime::Format::Natural;
use Test::More tests => 106;

my @with_suffix = (
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
    'for 1 seconds',
    'for 1 minutes',
    'for 1 hours',
    'for 1 days',
    'for 1 weeks',
    'for 1 months',
    'for 1 years',
);

my @without_suffix = (
    '2 second ago',
    '2 minute ago',
    '2 hour ago',
    '2 day ago',
    '2 week ago',
    '2 month ago',
    '2 year ago',
    'tomorrow 2 second ago',
    'tomorrow 2 minute ago',
    'tomorrow 2 hour ago',
    'tomorrow 2 day ago',
    'tomorrow 2 week ago',
    'tomorrow 2 month ago',
    'tomorrow 2 year ago',
    'yesterday 2 second ago',
    'yesterday 2 minute ago',
    'yesterday 2 hour ago',
    'yesterday 2 day ago',
    'yesterday 2 week ago',
    'yesterday 2 month ago',
    'yesterday 2 year ago',
    'fri 2 month ago at 5am',
    'wednesday 2 month ago at 8pm',
    '2 minute before now',
    '2 minute from now',
    '2 hour from now',
    '2 hour before now',
    '2 day before now',
    '2 day from now',
    '2 week before now',
    '2 week from now',
    '2 month before now',
    '2 month from now',
    '2 year before now',
    '2 year from now',
    'in 2 minute',
    'in 2 hour',
    'in 2 day',
    '2 hour before tomorrow',
    '2 hour before yesterday',
    '2 hour after tomorrow',
    '2 hour after yesterday',
    '2 hour before noon',
    '2 hour after noon',
    '2 hour before midnight',
    '2 hour after midnight',
    'for 2 second',
    'for 2 minute',
    'for 2 hour',
    'for 2 day',
    'for 2 week',
    'for 2 month',
    'for 2 year',
);

check(\@with_suffix);
check(\@without_suffix);

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
