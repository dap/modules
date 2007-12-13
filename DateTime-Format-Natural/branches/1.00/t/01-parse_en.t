#!/usr/bin/perl

use strict;
use warnings;

use DateTime::Format::Natural;
use Test::More tests => 149;

my ($sec, $min, $hour, $day, $month, $year) = (00, 13, 01, 24, 11, 2006);

my %simple = ('now'                   => '24.11.2006 01:13:00',
              'today'                 => '24.11.2006 01:13:00',
              'yesterday'             => '23.11.2006 01:13:00',
              'tomorrow'              => '25.11.2006 01:13:00',
              'morning'               => '24.11.2006 08:00:00',
              'afternoon'             => '24.11.2006 14:00:00',
              'evening'               => '24.11.2006 20:00:00',
              'noon'                  => '24.11.2006 12:00:00',
              'midnight'              => '24.11.2006 00:00:00',
              'yesterday at noon'     => '23.11.2006 12:00:00',
              'yesterday at midnight' => '23.11.2006 00:00:00',
              'today at noon'         => '24.11.2006 12:00:00',
              'today at midnight'     => '24.11.2006 00:00:00',
              'tomorrow at noon'      => '25.11.2006 12:00:00',
              'tomorrow at midnight'  => '25.11.2006 00:00:00',
              'this morning'          => '24.11.2006 08:00:00',
              'this afternoon'        => '24.11.2006 14:00:00',
              'this evening'          => '24.11.2006 20:00:00',
              'yesterday morning'     => '23.11.2006 08:00:00',
              'yesterday afternoon'   => '23.11.2006 14:00:00',
              'yesterday evening'     => '23.11.2006 20:00:00',
              'today morning'         => '24.11.2006 08:00:00',
              'today afternoon'       => '24.11.2006 14:00:00',
              'today evening'         => '24.11.2006 20:00:00',
              'tomorrow morning'      => '25.11.2006 08:00:00',
              'tomorrow afternoon'    => '25.11.2006 14:00:00',
              'tomorrow evening'      => '25.11.2006 20:00:00',
              'march'                 => '24.03.2006 01:13:00',
              '4th february'          => '04.02.2006 01:13:00',
              'november 3rd'          => '03.11.2006 01:13:00',
              'saturday'              => '25.11.2006 01:13:00',
              'last wednesday'        => '15.11.2006 01:13:00',
              'last june'             => '24.06.2005 01:13:00',
              'last month'            => '24.10.2006 01:13:00',
              'last year'             => '24.11.2005 01:13:00',
              'next friday'           => '01.12.2006 01:13:00',
              'next october'          => '24.10.2007 01:13:00',
              'next month'            => '24.12.2006 01:13:00',
              'next year'             => '24.11.2007 01:13:00',
              'this thursday'         => '23.11.2006 01:13:00',
              'this month'            => '24.11.2006 01:13:00',
              '6 am'                  => '24.11.2006 06:00:00',
              '5am'                   => '24.11.2006 05:00:00',
              '5am yesterday'         => '23.11.2006 05:00:00',
              '5am today'             => '24.11.2006 05:00:00',
              '5am tomorrow'          => '25.11.2006 05:00:00',
              '8 pm'                  => '24.11.2006 20:00:00',
              '4pm'                   => '24.11.2006 16:00:00',
              '4pm yesterday'         => '23.11.2006 16:00:00',
              '4pm today'             => '24.11.2006 16:00:00',
              '4pm tomorrow'          => '25.11.2006 16:00:00',
              'sunday 11:00'          => '26.11.2006 11:00:00',
              'mon 2:35'              => '20.11.2006 02:35:00',
              '13:45'                 => '24.11.2006 13:45:00',
              'may 2002'              => '24.05.2002 01:13:00',
              '2nd monday'            => '13.11.2006 01:13:00',
              '100th day'             => '10.04.2006 01:13:00',
              '6 in the morning'      => '24.11.2006 06:00:00',
              'sat 7 in the evening'  => '25.11.2006 19:00:00',
              'this second'           => '24.11.2006 01:13:00',
              'yesterday at 4:00'     => '23.11.2006 04:00:00',
              'last january'          => '24.01.2005 01:13:00',
              'last friday at 20:00'  => '17.11.2006 20:00:00',
              'tomorrow at 6:45pm'    => '25.11.2006 18:45:00',
              'yesterday afternoon'   => '23.11.2006 14:00:00',
              'thursday last week'    => '16.11.2006 01:13:00');

my %complex = ('6 in the morning'                => '24.11.2006 06:00:00',
               '4 in the afternoon'              => '24.11.2006 16:00:00',
               '9 in the evening'                => '24.11.2006 21:00:00',
               '25 seconds ago'                  => '24.11.2006 01:12:35',
               '10 minutes ago'                  => '24.11.2006 01:03:00',
               '7 hours ago'                     => '23.11.2006 18:13:00',
               '40 days ago'                     => '15.10.2006 01:13:00',
               '2 weeks ago'                     => '10.11.2006 01:13:00',
               '5 months ago'                    => '24.06.2006 01:13:00',
               '3 years ago'                     => '24.11.2003 01:13:00',
               'tomorrow 25 seconds ago'         => '25.11.2006 01:12:35',
               'tomorrow 10 minutes ago'         => '25.11.2006 01:03:00',
               'tomorrow 7 hours ago'            => '24.11.2006 18:13:00',
               'tomorrow 40 days ago'            => '16.10.2006 01:13:00',
               'tomorrow 2 weeks ago'            => '11.11.2006 01:13:00',
               'tomorrow 5 months ago'           => '25.06.2006 01:13:00',
               'tomorrow 3 years ago'            => '25.11.2003 01:13:00',
               'yesterday 25 seconds ago'        => '23.11.2006 01:12:35',
               'yesterday 10 minutes ago'        => '23.11.2006 01:03:00',
               'yesterday 7 hours ago'           => '22.11.2006 18:13:00',
               'yesterday 40 days ago'           => '14.10.2006 01:13:00',
               'yesterday 2 weeks ago'           => '09.11.2006 01:13:00',
               'yesterday 5 months ago'          => '23.06.2006 01:13:00',
               'yesterday 3 years ago'           => '23.11.2003 01:13:00',
               'fri 3 months ago at 5am'         => '25.08.2006 05:00:00',
               'wednesday 1 month ago at 8pm'    => '25.10.2006 20:00:00',
               '42 minutes before now'           => '24.11.2006 00:31:00',
               '42 minutes from now'             => '24.11.2006 01:55:00',
               '4 hours from now'                => '24.11.2006 05:13:00',
               '4 hours before now'              => '23.11.2006 21:13:00',
               '7 days before now'               => '17.11.2006 01:13:00',
               '7 days from now'                 => '01.12.2006 01:13:00',
               '4 weeks before now'              => '27.10.2006 01:13:00',
               '4 weeks from now'                => '22.12.2006 01:13:00',
               '13 months before now'            => '24.10.2005 01:13:00',
               '13 months from now'              => '24.12.2007 01:13:00',
               '2 years before now'              => '24.11.2004 01:13:00',
               '2 years from now'                => '24.11.2008 01:13:00',
               'tuesday 4 in the morning'        => '21.11.2006 04:00:00',
               'thursday 2 in the afternoon'     => '23.11.2006 14:00:00',
               'monday 6 in the evening'         => '20.11.2006 18:00:00',
               'last sunday at 21:45'            => '19.11.2006 21:45:00',
               'last week friday'                => '17.11.2006 01:13:00',
               'monday last week'                => '13.11.2006 01:13:00',
               '2nd day last week'               => '14.11.2006 01:13:00',
               '10th day last month'             => '10.10.2006 01:13:00',
               'tuesday next week'               => '28.11.2006 01:13:00',
               '3rd day next month'              => '03.12.2006 01:13:00',
               '10th month next year'            => '24.10.2007 01:13:00',
               'in 42 minutes'                   => '24.11.2006 01:55:00',
               'in 3 hours'                      => '24.11.2006 04:13:00',
               'in 5 days'                       => '29.11.2006 01:13:00',
               'wednesday this week'             => '22.11.2006 01:13:00',
               '3rd tuesday this november'       => '21.11.2006 01:13:00',
               '3 hours before tomorrow'         => '24.11.2006 21:13:00',
               '6 hours before yesterday'        => '22.11.2006 18:13:00',
               '9 hours after tomorrow'          => '25.11.2006 09:13:00',
               '12 hours after yesterday'        => '23.11.2006 12:13:00',
               '3 hours before noon'             => '24.11.2006 09:00:00',
               '6 hours after noon'              => '24.11.2006 18:00:00',
               '9 hours before midnight'         => '23.11.2006 15:00:00',
               '12 hours after midnight'         => '24.11.2006 12:00:00',
               'yesterday at 16:00'              => '23.11.2006 16:00:00',
               'today at 6:00'                   => '24.11.2006 06:00:00',
               'tomorrow at 12'                  => '25.11.2006 12:00:00',
               'tomorrow at 12'                  => '25.11.2006 12:00:00',
               'wednesday at 14:30'              => '22.11.2006 14:30:00',
               '2nd friday in august'            => '11.08.2006 01:13:00',
               'tomorrow 1 year ago'             => '25.11.2005 01:13:00',
               'saturday 3 months ago at 5:00pm' => '26.08.2006 17:00:00',
               '4th day last week'               => '16.11.2006 01:13:00',
               '3rd wednesday in november'       => '15.11.2006 01:13:00',
               '3rd month next year'             => '24.03.2007 01:13:00');

my %specific = ('january 11'        => '11.01.2006 01:13:00',
                '11 january'        => '11.01.2006 01:13:00',
                'dec 25'            => '25.12.2006 01:13:00',
                'may 27th'          => '27.05.2006 01:13:00',
                'October 2006'      => '24.10.2006 01:13:00',
                'february 14, 2004' => '14.02.2004 01:13:00',
                'Friday'            => '24.11.2006 01:13:00',
                'jan 3 2010'        => '03.01.2010 01:13:00',
                '3 jan 2000'        => '03.01.2000 01:13:00',
                '27/5/1979'         => '27.05.1979 01:13:00',
                '4:00'              => '24.11.2006 04:00:00',
                '17:00'             => '24.11.2006 17:00:00');

compare(\%simple);
compare(\%complex);
compare(\%specific);

sub compare
{
    my $href = shift;
    foreach my $key (sort keys %$href) {
        compare_strings($key, $href->{$key});
    }
}

sub compare_strings
{
    my ($string, $result) = @_;

    my $parse = DateTime::Format::Natural->new(lang => 'en');
    $parse->_set_datetime($year, $month, $day, $hour, $min, $sec);

    my $dt = $parse->parse_datetime(string => $string);

    my $res_string = sprintf("%02d.%02d.%4d %02d:%02d:%02d", $dt->day, $dt->month, $dt->year, $dt->hour, $dt->min, $dt->sec);

    if ($parse->success) {
        is($res_string, $result, $string);
    }
    else {
        fail($string);
    }
}
