#!/usr/bin/perl

use strict;
use warnings;

use DateTime::Format::Natural;
use Test::More tests => 65;

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

compare(\%simple);

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

    my $parse = DateTime::Format::Natural->new(lang => 'en', time_zone => 'UTC');
    $parse->_set_datetime($year, $month, $day, $hour, $min, $sec, 'Asia/Tokyo');
    
    my $dt = $parse->parse_datetime(string => $string);

    my $res_string = sprintf("%02d.%02d.%4d %02d:%02d:%02d", $dt->day, $dt->month, $dt->year, $dt->hour, $dt->min, $dt->sec);

    if ($parse->success) {
        is($res_string, $result, $string);
    }
    else {
        fail($string);
    }
}

