#!/usr/bin/perl

use strict;
use warnings;

use DateTime::Format::Natural;
use Test::More tests => 6;

my ($sec, $min, $hour, $day, $month, $year) = (00, 13, 01, 24, 11, 2006);

my %daytime_regular = ('morning'   => '24.11.2006 08:00:00',
                       'afternoon' => '24.11.2006 14:00:00',
                       'evening'   => '24.11.2006 20:00:00');

my %daytime_user = ('morning (user)'   => '24.11.2006 06:00:00',
                    'afternoon (user)' => '24.11.2006 13:00:00',
                    'evening (user)'   => '24.11.2006 19:00:00');

compare(\%daytime_regular);
compare(\%daytime_user, { morning => 06, afternoon => 13, evening => 19 });

sub compare {
    my ($href, $opts) = @_;
    foreach my $key (sort keys %$href) {
        compare_strings($key, $href->{$key}, $opts);
    }
}

sub compare_strings {
    my ($string, $result, $opts) = @_;

    my $parse = DateTime::Format::Natural->new(
                lang => 'en',
                daytime => $opts || {},
    );
    $parse->_set_datetime($year, $month, $day, $hour, $min, $sec);

    my $dt = $parse->parse_datetime(string => $string);

    my $res_string = sprintf("%02s.%02s.%4s %02s:%02s:%02s", $dt->day, $dt->month, $dt->year, $dt->hour, $dt->min, $dt->sec);
    is($res_string, $result, $string);
}
