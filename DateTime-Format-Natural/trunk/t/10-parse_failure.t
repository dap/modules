#!/usr/bin/perl

use strict;
use warnings;
use boolean qw(false);

use DateTime::Format::Natural;
use Test::More tests => 240;

my %errors = (
    with_suffix      => qr/suffix 's' without plural/,
    without_suffix   => qr/plural without suffix 's'/,
    meridiem_exceeds => qr/hour exceeds 12-hour clock/,
    meridiem_zero    => qr/hour zero must be literal 12/,
    ordinal_number   => qr/letter suffix should be '(?:st|nd|rd|th)'/,
);

my @with_suffix = ($errors{with_suffix},
[
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
]);

my @without_suffix = ($errors{without_suffix},
[
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
]);

my @meridiem_exceeds = ($errors{meridiem_exceeds},
[
    '13am yesterday',
    '13am today',
    '13am tomorrow',
    '14pm yesterday',
    '14pm today',
    '14pm tomorrow',
    '15am next monday',
    '15am this monday',
    '15am last monday',
    '16pm next friday',
    '16pm this friday',
    '16pm last friday',
    'may 02 17am',
    'may 02 17pm',
    '18 am',
    '18 pm',
    '19:00:00 am',
    '19:00:00 pm',
    '20am',
    '20pm',
    'sunday 21am',
    'sunday 21pm',
    '22am saturday',
    '22pm saturday',
    'tuesday 1 month ago at 23am',
    'tuesday 1 month ago at 23pm',
    'yesterday 13am',
    'today 13am',
    'tomorrow 13am',
    'yesterday 14pm',
    'today 14pm',
    'tomorrow 14pm',
    'yesterday at 15am',
    'today at 15am',
    'tomorrow at 15am',
    'yesterday at 16 am',
    'today at 16 am',
    'tomorrow at 16 am',
    'yesterday at 17 pm',
    'today at 17 pm',
    'tomorrow at 17 pm',
    'wednesday at 18am',
    'wednesday at 18pm',
    '19am on thursday',
    '19pm on thursday',
    'sunday at 20 am',
    'sunday at 20 pm',
    'saturday 21 am',
    'saturday 21 pm',
    'yesterday at 22pm',
    'today at 22pm',
    'tomorrow at 22pm',
]);

my @meridiem_zero = ($errors{meridiem_zero},
[
    '0am yesterday',
    '0am today',
    '0am tomorrow',
    '0pm yesterday',
    '0pm today',
    '0pm tomorrow',
    '0am next monday',
    '0am this monday',
    '0am last monday',
    '0pm next friday',
    '0pm this friday',
    '0pm last friday',
    'may 02 0am',
    'may 02 0pm',
    '0 am',
    '0 pm',
    '00:00:00 am',
    '00:00:00 pm',
    '0am',
    '0pm',
    'sunday 0am',
    'sunday 0pm',
    '0am saturday',
    '0pm saturday',
    'tuesday 1 month ago at 0am',
    'tuesday 1 month ago at 0pm',
    'yesterday 0am',
    'today 0am',
    'tomorrow 0am',
    'yesterday 0pm',
    'today 0pm',
    'tomorrow 0pm',
    'yesterday at 0am',
    'today at 0am',
    'tomorrow at 0am',
    'yesterday at 0 am',
    'today at 0 am',
    'tomorrow at 0 am',
    'yesterday at 0 pm',
    'today at 0 pm',
    'tomorrow at 0 pm',
    'wednesday at 0am',
    'wednesday at 0pm',
    '0am on thursday',
    '0pm on thursday',
    'sunday at 0 am',
    'sunday at 0 pm',
    'saturday 0 am',
    'saturday 0 pm',
    'yesterday at 0pm',
    'today at 0pm',
    'tomorrow at 0pm',
]);

my @ordinal_number = ($errors{ordinal_number},
[
    '4st february',
    'november 3nd',
    'feb 28rd 3:00',
    'feb 28rd 3am',
    'feb 28rd 3pm',
    '11st january 2 years ago',
    '11st january next year',
    '11st january this year',
    '11st january last year',
    'march 1rd 2009',
    '2th monday',
    '100st day',
    '1nd day next year',
    '1nd day this year',
    '1nd day last year',
    '6rd day next week',
    '6rd day this week',
    '6rd day last week',
    '12st day next month',
    '12st day this month',
    '12st day last month',
    '8nd month next year',
    '8nd month this year',
    '8nd month last year',
    '1nd tuesday next november',
    '1nd tuesday this november',
    '1nd tuesday last november',
    '3th jan 2000',
    'jan 3th 2000',
    '2st friday in august',
]);

check(\@with_suffix);
check(\@without_suffix);
check(\@meridiem_exceeds);
check(\@meridiem_zero);
check(\@ordinal_number);

sub check
{
    my $aref = shift;
    my ($error, $checks) = @$aref;
    foreach my $string (@$checks) {
        check_fail($error, $string);
    }
}

sub check_fail
{
    my ($error, $string) = @_;

    my $parser = DateTime::Format::Natural->new;
    $parser->parse_datetime($string);

    my $check_error = sub
    {
        my ($parser_error) = @_;
        return false unless defined $parser_error;
        return                      $parser_error =~ /^\($error\)$/;
    };

    # Examine _get_error() to detect whether an extended check
    # failed rather than a generic parse failure occurred.
    if (!$parser->success && $check_error->($parser->_get_error)) {
        pass($string);
    }
    else {
        fail($string);
    }
}
