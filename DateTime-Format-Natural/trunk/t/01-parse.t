#!/usr/bin/perl

use strict;
use warnings;
use boolean qw(true);

use DateTime::Format::Natural;
use Test::More;

my ($sec, $min, $hour, $day, $month, $year) = (8, 13, 1, 24, 11, 2006);

my @simple = (
    { 'now'                   => '24.11.2006 01:13:08' },
    { 'yesterday'             => '23.11.2006 00:00:00' },
    { 'today'                 => '24.11.2006 00:00:00' },
    { 'tomorrow'              => '25.11.2006 00:00:00' },
    { 'morning'               => '24.11.2006 08:00:00' },
    { 'afternoon'             => '24.11.2006 14:00:00' },
    { 'evening'               => '24.11.2006 20:00:00' },
    { 'noon'                  => '24.11.2006 12:00:00' },
    { 'midnight'              => '24.11.2006 00:00:00' },
    { 'yesterday at noon'     => '23.11.2006 12:00:00' },
    { 'yesterday at midnight' => '23.11.2006 00:00:00' },
    { 'today at noon'         => '24.11.2006 12:00:00' },
    { 'today at midnight'     => '24.11.2006 00:00:00' },
    { 'tomorrow at noon'      => '25.11.2006 12:00:00' },
    { 'tomorrow at midnight'  => '25.11.2006 00:00:00' },
    { 'this morning'          => '24.11.2006 08:00:00' },
    { 'this afternoon'        => '24.11.2006 14:00:00' },
    { 'this evening'          => '24.11.2006 20:00:00' },
    { 'yesterday morning'     => '23.11.2006 08:00:00' },
    { 'yesterday afternoon'   => '23.11.2006 14:00:00' },
    { 'yesterday evening'     => '23.11.2006 20:00:00' },
    { 'today morning'         => '24.11.2006 08:00:00' },
    { 'today afternoon'       => '24.11.2006 14:00:00' },
    { 'today evening'         => '24.11.2006 20:00:00' },
    { 'tomorrow morning'      => '25.11.2006 08:00:00' },
    { 'tomorrow afternoon'    => '25.11.2006 14:00:00' },
    { 'tomorrow evening'      => '25.11.2006 20:00:00' },
    { '5am yesterday'         => '23.11.2006 05:00:00' },
    { '5am today'             => '24.11.2006 05:00:00' },
    { '5am tomorrow'          => '25.11.2006 05:00:00' },
    { '4pm yesterday'         => '23.11.2006 16:00:00' },
    { '4pm today'             => '24.11.2006 16:00:00' },
    { '4pm tomorrow'          => '25.11.2006 16:00:00' },
    { 'last second'           => '24.11.2006 01:13:07' },
    { 'this second'           => '24.11.2006 01:13:08' },
    { 'next second'           => '24.11.2006 01:13:09' },
    { 'last minute'           => '24.11.2006 01:12:00' },
    { 'this minute'           => '24.11.2006 01:13:00' },
    { 'next minute'           => '24.11.2006 01:14:00' },
    { 'last hour'             => '24.11.2006 00:00:00' },
    { 'this hour'             => '24.11.2006 01:00:00' },
    { 'next hour'             => '24.11.2006 02:00:00' },
    { 'last day'              => '23.11.2006 00:00:00' },
    { 'this day'              => '24.11.2006 00:00:00' },
    { 'next day'              => '25.11.2006 00:00:00' },
    { 'last week'             => '17.11.2006 00:00:00' },
    { 'this week'             => '24.11.2006 00:00:00' },
    { 'next week'             => '01.12.2006 00:00:00' },
    { 'last month'            => '01.10.2006 00:00:00' },
    { 'this month'            => '01.11.2006 00:00:00' },
    { 'next month'            => '01.12.2006 00:00:00' },
    { 'last year'             => '01.01.2005 00:00:00' },
    { 'this year'             => '01.01.2006 00:00:00' },
    { 'next year'             => '01.01.2007 00:00:00' },
    { 'last friday'           => '17.11.2006 00:00:00' },
    { 'this friday'           => '24.11.2006 00:00:00' },
    { 'next friday'           => '01.12.2006 00:00:00' },
    { 'tuesday last week'     => '14.11.2006 00:00:00' },
    { 'tuesday this week'     => '21.11.2006 00:00:00' },
    { 'tuesday next week'     => '28.11.2006 00:00:00' },
    { 'last week wednesday'   => '15.11.2006 00:00:00' },
    { 'this week wednesday'   => '22.11.2006 00:00:00' },
    { 'next week wednesday'   => '29.11.2006 00:00:00' },
    { '10 seconds ago'        => '24.11.2006 01:12:58' },
    { '10 minutes ago'        => '24.11.2006 01:03:08' },
    { '10 hours ago'          => '23.11.2006 15:13:08' },
    { '10 days ago'           => '14.11.2006 01:13:08' },
    { '10 weeks ago'          => '15.09.2006 01:13:08' },
    { '10 months ago'         => '24.01.2006 01:13:08' },
    { '10 years ago'          => '24.11.1996 01:13:08' },
    { 'in 5 seconds'          => '24.11.2006 01:13:13' },
    { 'in 5 minutes'          => '24.11.2006 01:18:08' },
    { 'in 5 hours'            => '24.11.2006 06:13:08' },
    { 'in 5 days'             => '29.11.2006 01:13:08' },
    { 'in 5 weeks'            => '29.12.2006 01:13:08' },
    { 'in 5 months'           => '24.04.2007 01:13:08' },
    { 'in 5 years'            => '24.11.2011 01:13:08' },
    { 'saturday'              => '25.11.2006 00:00:00' },
    { 'sunday 11:00'          => '26.11.2006 11:00:00' },
    { 'yesterday at 4:00'     => '23.11.2006 04:00:00' },
    { 'today at 4:00'         => '24.11.2006 04:00:00' },
    { 'tomorrow at 4:00'      => '25.11.2006 04:00:00' },
    { 'yesterday at 6:45pm'   => '23.11.2006 18:45:00' },
    { 'today at 6:45pm'       => '24.11.2006 18:45:00' },
    { 'tomorrow at 6:45pm'    => '25.11.2006 18:45:00' },
    { 'wednesday at 14:30'    => '22.11.2006 14:30:00' },
    { 'wednesday at 02:30pm'  => '22.11.2006 14:30:00' },
    { '2nd monday'            => '13.11.2006 00:00:00' },
    { '100th day'             => '10.04.2006 00:00:00' },
    { '4th february'          => '04.02.2006 00:00:00' },
    { 'november 3rd'          => '03.11.2006 00:00:00' },
    { 'last june'             => '01.06.2005 00:00:00' },
    { 'next october'          => '01.10.2007 00:00:00' },
    { '6 am'                  => '24.11.2006 06:00:00' },
    { '5am'                   => '24.11.2006 05:00:00' },
    { '5:30am'                => '24.11.2006 05:30:00' },
    { '8 pm'                  => '24.11.2006 20:00:00' },
    { '4pm'                   => '24.11.2006 16:00:00' },
    { '4:20pm'                => '24.11.2006 16:20:00' },
    { 'mon 2:35'              => '20.11.2006 02:35:00' },
);

my @complex = (
    { 'yesterday 7 seconds ago'         => '23.11.2006 01:13:01' },
    { 'yesterday 7 minutes ago'         => '23.11.2006 01:06:08' },
    { 'yesterday 7 hours ago'           => '22.11.2006 18:13:08' },
    { 'yesterday 7 days ago'            => '16.11.2006 01:13:08' },
    { 'yesterday 7 weeks ago'           => '05.10.2006 01:13:08' },
    { 'yesterday 7 months ago'          => '23.04.2006 01:13:08' },
    { 'yesterday 7 years ago'           => '23.11.1999 01:13:08' },
    { 'tomorrow 3 seconds ago'          => '25.11.2006 01:13:05' },
    { 'tomorrow 3 minutes ago'          => '25.11.2006 01:10:08' },
    { 'tomorrow 3 hours ago'            => '24.11.2006 22:13:08' },
    { 'tomorrow 3 days ago'             => '22.11.2006 01:13:08' },
    { 'tomorrow 3 weeks ago'            => '04.11.2006 01:13:08' },
    { 'tomorrow 3 months ago'           => '25.08.2006 01:13:08' },
    { 'tomorrow 3 years ago'            => '25.11.2003 01:13:08' },
    { '2 seconds before now'            => '24.11.2006 01:13:06' },
    { '2 minutes before now'            => '24.11.2006 01:11:08' },
    { '2 hours before now'              => '23.11.2006 23:13:08' },
    { '2 days before now'               => '22.11.2006 01:13:08' },
    { '2 weeks before now'              => '10.11.2006 01:13:08' },
    { '2 months before now'             => '24.09.2006 01:13:08' },
    { '2 years before now'              => '24.11.2004 01:13:08' },
    { '4 seconds from now'              => '24.11.2006 01:13:12' },
    { '4 minutes from now'              => '24.11.2006 01:17:08' },
    { '4 hours from now'                => '24.11.2006 05:13:08' },
    { '4 days from now'                 => '28.11.2006 01:13:08' },
    { '4 weeks from now'                => '22.12.2006 01:13:08' },
    { '4 months from now'               => '24.03.2007 01:13:08' },
    { '4 years from now'                => '24.11.2010 01:13:08' },
    { '6 in the morning'                => '24.11.2006 06:00:00' },
    { '4 in the afternoon'              => '24.11.2006 16:00:00' },
    { '9 in the evening'                => '24.11.2006 21:00:00' },
    { 'monday 6 in the morning'         => '20.11.2006 06:00:00' },
    { 'monday 4 in the afternoon'       => '20.11.2006 16:00:00' },
    { 'monday 9 in the evening'         => '20.11.2006 21:00:00' },
    { 'last sunday at 21:45'            => '19.11.2006 21:45:00' },
    { 'monday last week'                => '13.11.2006 00:00:00' },
    { '6th day last week'               => '18.11.2006 00:00:00' },
    { '6th day this week'               => '25.11.2006 00:00:00' },
    { '6th day next week'               => '02.12.2006 00:00:00' },
    { '12th day last month'             => '12.10.2006 00:00:00' },
    { '12th day this month'             => '12.11.2006 00:00:00' },
    { '12th day next month'             => '12.12.2006 00:00:00' },
    { '1st day last year'               => '01.01.2005 00:00:00' },
    { '1st day this year'               => '01.01.2006 00:00:00' },
    { '1st day next year'               => '01.01.2007 00:00:00' },
    { '1st tuesday last november'       => '01.11.2005 00:00:00' },
    { '1st tuesday this november'       => '07.11.2006 00:00:00' },
    { '1st tuesday next november'       => '06.11.2007 00:00:00' },
    { '11 january next year'            => '11.01.2007 00:00:00' },
    { '11 january this year'            => '11.01.2006 00:00:00' },
    { '11 january last year'            => '11.01.2005 00:00:00' },
    { '6 hours before yesterday'        => '22.11.2006 18:00:00' },
    { '6 hours before tomorrow'         => '24.11.2006 18:00:00' },
    { '3 hours after yesterday'         => '23.11.2006 03:00:00' },
    { '3 hours after tomorrow'          => '25.11.2006 03:00:00' },
    { '10 hours before noon'            => '24.11.2006 02:00:00' },
    { '10 hours before midnight'        => '23.11.2006 14:00:00' },
    { '5 hours after noon'              => '24.11.2006 17:00:00' },
    { '5 hours after midnight'          => '24.11.2006 05:00:00' },
    { 'last friday at 20:00'            => '17.11.2006 20:00:00' },
    { 'this friday at 20:00'            => '24.11.2006 20:00:00' },
    { 'next friday at 20:00'            => '01.12.2006 20:00:00' },
    { 'yesterday at 13:00'              => '23.11.2006 13:00:00' },
    { 'today at 13:00'                  => '24.11.2006 13:00:00' },
    { 'tomorrow at 13'                  => '25.11.2006 13:00:00' },
    { '2nd friday in august'            => '11.08.2006 00:00:00' },
    { '3rd wednesday in november'       => '15.11.2006 00:00:00' },
    { 'tomorrow 1 year ago'             => '25.11.2005 01:13:08' },
    { 'saturday 3 months ago at 5:00pm' => '26.08.2006 17:00:00' },
    { '11 january 2 years ago'          => '11.01.2004 00:00:00' },
    { '4th day last week'               => '16.11.2006 00:00:00' },
    { '8th month last year'             => '01.08.2005 00:00:00' },
    { '8th month this year'             => '01.08.2006 00:00:00' },
    { '8th month next year'             => '01.08.2007 00:00:00' },
    { '6 mondays from now'              => '01.01.2007 00:00:00' },
    { 'fri 3 months ago at 5am'         => '25.08.2006 05:00:00' },
    { 'wednesday 1 month ago at 8pm'    => '25.10.2006 20:00:00' },
    { 'final thursday in april'         => '27.04.2006 00:00:00' },
    { 'final sunday in april'           => '30.04.2006 00:00:00' }, # edge case
);

my @specific = (
    { 'march'             => '01.03.2006 00:00:00' },
    { 'january 11'        => '11.01.2006 00:00:00' },
    { '11 january'        => '11.01.2006 00:00:00' },
    { 'dec 25'            => '25.12.2006 00:00:00' },
    { 'may 27th'          => '27.05.2006 00:00:00' },
  # { '2005'              => '01.01.2005 00:00:00' },
    { 'march 1st 2009'    => '01.03.2009 00:00:00' },
    { 'October 2006'      => '01.10.2006 00:00:00' },
    { 'february 14, 2004' => '14.02.2004 00:00:00' },
    { 'jan 3 2010'        => '03.01.2010 00:00:00' },
    { '3 jan 2000'        => '03.01.2000 00:00:00' },
    { '27/5/1979'         => '27.05.1979 00:00:00' },
    { '4:00'              => '24.11.2006 04:00:00' },
    { '17:00'             => '24.11.2006 17:00:00' },
    { '3:20:00'           => '24.11.2006 03:20:00' },
);

{
    my $tests = 193;

    local $@;

    if (eval "require Date::Calc") {
        plan tests => $tests * 2;
        compare(\@simple);
        compare(\@complex);
        compare(\@specific);
    }
    else {
        plan tests => $tests;
    }

    $DateTime::Format::Natural::Compat::Pure = true;

    compare(\@simple);
    compare(\@complex);
    compare(\@specific);
}

sub compare
{
    my $aref = shift;
    foreach my $href (@$aref) {
        my $key = (keys %$href)[0];
        compare_strings($key, $href->{$key});
    }
}

sub compare_strings
{
    my ($string, $result) = @_;

    my $parser = DateTime::Format::Natural->new;
    $parser->_set_datetime($year, $month, $day, $hour, $min, $sec);

    my $dt = $parser->parse_datetime($string);

    my $res_string = sprintf('%02d.%02d.%4d %02d:%02d:%02d', $dt->day, $dt->month, $dt->year, $dt->hour, $dt->min, $dt->sec);

    if ($parser->success) {
        is($res_string, $result, $string);
    }
    else {
        fail($string);
    }
}
