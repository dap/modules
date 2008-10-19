package DateTime::Format::Natural::Lang::EN;

use strict;
use warnings;
use base qw(DateTime::Format::Natural::Lang::Base);

our $VERSION = '1.13';

our (%init,
     %timespan,
     %RE,
     %data_weekdays,
     %data_weekdays_abbrev,
     @data_weekdays_all,
     %data_months,
     %data_months_abbrev,
     @data_months_all,
     %grammar);

%init = ('tokens' => sub {});
%timespan = ('literal' => 'to');

%RE = ('number'    => qr/^(\d+)$/,
       'year'      => qr/^(\d{4})$/,
       'time'      => qr/^((?:\d{1,2})(?:\:\d{1,2})?)$/,
       'time_am'   => qr/^((?:\d+)(?:\:\d+)?)(?:am)?$/,
       'time_pm'   => qr/^((?:\d+)(?:\:\d+)?)pm$/,
       'time_full' => qr/^(\d{2}\:\d{2}:\d{2})$/,
       'day_enum'  => qr/^(\d+)(?:st|nd|rd|th)?$/,
       'monthday'  => qr/^(\d{1,2})$/);
{
    my $i = 1;

    %data_weekdays = map {
        $_ => $i++
    } qw(Monday Tuesday Wednesday Thursday Friday Saturday Sunday);
    %data_weekdays_abbrev = map {
        substr($_, 0, 3) => $_
    } keys %data_weekdays;

    @data_weekdays_all = (keys %data_weekdays, keys %data_weekdays_abbrev);

    my $days_re = join '|', @data_weekdays_all;
    $RE{weekday} = qr/^($days_re)$/i;

    $i = 1;

    %data_months = map {
        $_ => $i++
    } qw(January February March April May June July August September
         October November December);
    %data_months_abbrev = map {
        substr($_, 0, 3) => $_
    } keys %data_months;

    @data_months_all = (keys %data_months, keys %data_months_abbrev);

    my $months_re = join '|', @data_months_all;
    $RE{month} = qr/^($months_re)$/i;
}

# <keyword> => [
#    [ <PERL TYPE DECLARATION>, ... ], ---------------------> declares how the tokens will be evaluated
#    [
#      { <token index> => <token value>, ... }, ------------> declares the index <-> value map 
#      [ [ <index(es) of token(s) to be passed> ], ... ], --> declares which tokens will be passed to the dispatch handler(s)
#      [ <name of subroutine to dispatch to>, ... ], -------> declares the dispatch handler(s)
#    ],

%grammar = (
    now => [
       [ 'SCALAR' ],
       [
         { 0 => 'now' },
         [ [] ],
         [ '_day_today' ],
       ],
    ],
    day => [
       [ 'SCALAR' ],
       [
         { 0 => 'today' },
         [ [] ],
         [ '_day_today' ],
       ],
       [
         { 0 => 'yesterday' },
         [ [] ],
         [ '_day_yesterday' ],
       ],
       [
         { 0 => 'tomorrow' },
         [ [] ],
         [ '_day_tomorrow' ],
       ],
    ],
    dayframe => [
       [ 'SCALAR' ],
       [
         { 0 => 'morning' },
         [ [] ],
         [ '_daytime_morning' ],
       ],
       [
         { 0 => 'afternoon' },
         [ [] ],
         [ '_daytime_afternoon' ],
       ],
       [
         { 0 => 'evening' },
         [ [] ],
         [ '_daytime_evening' ],
       ]
    ],
    daytime_noon_midnight => [
       [ 'SCALAR' ],
       [
         { 0 => 'noon' },
         [ [] ],
         [ '_daytime_noon' ],
       ],
       [
         { 0 => 'midnight' },
         [ [] ],
         [ '_daytime_midnight' ],
       ],
    ],
    daytime_noon_midnight_at => [
       [ 'SCALAR', 'SCALAR', 'SCALAR' ],
       [
         { 0 => 'yesterday', 1 => 'at', 2 => 'noon' },
         [ [], [] ],
         [ '_day_yesterday', '_daytime_noon' ],
       ],
       [
         { 0 => 'yesterday', 1 => 'at', 2 => 'midnight' },
         [ [], [] ],
         [ '_day_yesterday', '_daytime_midnight' ],
       ],
       [
         { 0 => 'today', 1 => 'at', 2 => 'noon' },
         [ [], [] ],
         [ '_day_today', '_daytime_noon' ],
       ],
       [
         { 0 => 'today', 1 => 'at', 2 => 'midnight' },
         [ [], [] ],
         [ '_day_today', '_daytime_midnight' ],
       ],
       [
         { 0 => 'tomorrow', 1 => 'at', 2 => 'noon' },
         [ [], [] ],
         [ '_day_tomorrow', '_daytime_noon' ],
       ],
       [
         { 0 => 'tomorrow', 1 => 'at', 2 => 'midnight' },
         [ [], [] ],
         [ '_day_tomorrow', '_daytime_midnight' ],
       ],
    ],
    this_daytime => [
       [ 'SCALAR', 'SCALAR' ],
       [
         { 0 => 'this', 1 => 'morning' },
         [ [] ],
         [ '_daytime_morning' ],
       ],
       [
         { 0 => 'this', 1 => 'afternoon' },
         [ [] ],
         [ '_daytime_afternoon' ],
       ],
       [
         { 0 => 'this', 1 => 'evening' },
         [ [] ],
         [ '_daytime_evening' ],
       ],
    ],
    dayframe_day => [
       [ 'SCALAR', 'SCALAR' ],
       [
         { 0 => 'yesterday', 1 => 'morning' },
         [ [], [] ],
         [ '_day_yesterday', '_daytime_morning' ],
       ],
       [
         { 0 => 'yesterday', 1 => 'afternoon' },
         [ [], [] ],
         [ '_day_yesterday', '_daytime_afternoon' ],
       ],
       [
         { 0 => 'yesterday', 1 => 'evening' },
         [ [], [] ],
         [ '_day_yesterday', '_daytime_evening' ],
       ],
       [
         { 0 => 'today', 1 => 'morning' },
         [ [], [] ],
         [ '_day_today', '_daytime_morning' ],
       ],
       [
         { 0 => 'today', 1 => 'afternoon' },
         [ [], [] ],
         [ '_day_today', '_daytime_afternoon' ],
       ],
       [
         { 0 => 'today', 1 => 'evening' },
         [ [], [] ],
         [ '_day_today', '_daytime_evening' ],
       ],
       [
         { 0 => 'tomorrow', 1 => 'morning' },
         [ [], [] ],
         [ '_day_tomorrow', '_daytime_morning' ],
       ],
       [
         { 0 => 'tomorrow', 1 => 'afternoon' },
         [ [], [] ],
         [ '_day_tomorrow', '_daytime_afternoon' ],
       ],
       [
         { 0 => 'tomorrow', 1 => 'evening' },
         [ [], [] ],
         [ '_day_tomorrow', '_daytime_evening' ],
       ]
    ],
    at_daytime => [
       [ 'REGEXP', 'SCALAR' ],
       [
         { 0 => $RE{time_am}, 1 => 'yesterday' },
         [ [ 0 ], [] ],
         [ '_time', '_day_yesterday' ],
       ],
       [
         { 0 => $RE{time_am}, 1 => 'today' },
         [ [ 0 ], [] ],
         [ '_time', '_day_today' ],
       ],
       [
         { 0 => $RE{time_am}, 1 => 'tomorrow' },
         [ [ 0 ], [] ],
         [ '_time', '_day_tomorrow' ],
       ],
       [
         { 0 => $RE{time_pm}, 1 => 'yesterday' },
         [ [ 0 ], [] ],
         [ '_at_pm', '_day_yesterday' ],
       ],
       [
         { 0 => $RE{time_pm}, 1 => 'today' },
         [ [ 0 ], [] ],
         [ '_at_pm', '_day_today' ],
       ],
       [
         { 0 => $RE{time_pm}, 1 => 'tomorrow' },
         [ [ 0 ], [] ],
         [ '_at_pm', '_day_tomorrow' ],
       ],
    ],
    month => [
       [ 'REGEXP' ],
       [
         { 0 => $RE{month} },
         [ [ 0 ] ],
         [ '_month' ],
       ],
    ],
    month_day => [
       [ 'REGEXP', 'REGEXP' ],
       [
         { 0 => $RE{day_enum}, 1 => $RE{month} },
         [ [ 0, 1 ] ],
         [ '_month_day_before' ],
       ],
       [
         { 0 => $RE{month}, 1 => $RE{day_enum} },
         [ [ 0, 1 ] ],
         [ '_month_day_after' ],
       ]
    ],
    weekday => [
       [ 'REGEXP' ],
       [
         { 0 => $RE{weekday} },
         [ [ 0 ] ],
         [ '_weekday' ],
       ],
    ],
    last_day => [
       [ 'SCALAR', 'REGEXP' ],
       [
         { 0 => 'last', 1 => $RE{weekday} },
         [ [ 1 ] ],
         [ '_last_day' ],
       ],
    ],
    last_month => [
       [ 'SCALAR', 'REGEXP' ],
       [
         { 0 => 'last', 1 => $RE{month} },
         [ [ 1 ] ],
         [ '_last_month' ],
       ],
    ],
    last_month_literal => [
       [ 'SCALAR', 'SCALAR' ],
       [
         { 0 => 'last', 1 => 'month' },
         [ [] ],
         [ '_last_month_literal' ],
       ],
    ],
    last_year => [
       [ 'SCALAR', 'SCALAR' ],
       [
         { 0 => 'last', 1 => 'year' },
         [ [] ],
         [ '_last_year' ],
       ],
    ],
    next_weekday => [
       [ 'SCALAR', 'REGEXP' ],
       [
         { 0 => 'next', 1 => $RE{weekday} },
         [ [ 1 ] ],
         [ '_next_weekday' ],
       ],
    ],
    next_month => [
       [ 'SCALAR', 'REGEXP' ],
       [
         { 0 => 'next', 1 => $RE{month} },
         [ [ 1 ] ],
         [ '_next_month' ],
       ],
    ],
    next_month_literal => [
       [ 'SCALAR', 'SCALAR' ],
       [
         { 0 => 'next', 1 => 'month' },
         [ [] ],
         [ '_next_month_literal' ],
       ],
    ],
    next_year => [
       [ 'SCALAR', 'SCALAR' ],
       [
         { 0 => 'next', 1 => 'year' },
         [ [] ],
         [ '_next_year' ],
       ],
    ],
    this_second => [
       [ 'SCALAR', 'SCALAR' ],
       [
         { 0 => 'this', 1 => 'second' },
         [ [] ],
         [ '_this_second' ],
       ],
    ],
    this_weekday => [
       [ 'SCALAR', 'REGEXP' ],
       [
         { 0 => 'this', 1 => $RE{weekday} },
         [ [ 1 ] ],
         [ '_this_weekday' ],
       ],
    ],
    this_month => [
       [ 'SCALAR', 'SCALAR' ],
       [
         { 0 => 'this', 1 => 'month' },
         [ [] ],
         [ '_this_month' ],
       ],
    ],
    at => [
       [ 'REGEXP', 'SCALAR' ],
       [
         { 0 => $RE{time}, 1 => 'am' },
         [ [ 0 ] ],
         [ '_at_am' ],
       ],
       [
         { 0 => $RE{time}, 1 => 'pm' },
         [ [ 0 ] ], 
         [ '_at_pm' ],
       ],
    ],
    at_combined => [
       [ 'REGEXP' ],
       [
         { 0 => qr/^(\d+)(?:am)$/i }, 
         [ [ 0 ] ],
         [ '_at_am' ],
       ],
       [
         { 0 => qr/^(\d+)(?:pm)$/i },
         [ [ 0 ] ],
         [ '_at_pm' ],
       ],
    ],
    weekday_time => [
       [ 'REGEXP', 'REGEXP' ],
       [
         { 0 => $RE{weekday}, 1 => $RE{time} },
         [ [ 0 ], [ 1 ] ],
         [ '_weekday', '_time' ],
       ],
    ],
    time => [
       [ 'REGEXP' ],
       [
         { 0 => $RE{time} },
         [ [ 0 ] ],
         [ '_time' ],
       ],
    ],
    time_full => [
       [ 'REGEXP' ],
       [
         { 0 => $RE{time_full} },
         [ [ 0 ] ],
         [ '_time_full' ],
       ],
    ],
    month_year => [
       [ 'REGEXP', 'REGEXP' ],
       [
         { 0 => $RE{month}, 1 => $RE{year} },
         [ [ 0 ], [ 1 ] ],
         [ '_month', '_year' ],
       ],
    ],
    year => [
       [ 'REGEXP' ],
       [
         { 0 => $RE{year} },
         [ [ 0 ] ],
         [ '_year' ],
       ],
    ],
    count_weekday => [
       [ 'REGEXP', 'REGEXP' ],
       [
         { 0 => $RE{day_enum}, 1 => $RE{weekday} },
         [ [ 0, 1 ] ],
         [ '_count_weekday' ],
       ],
    ],
    count_yearday => [
       [ 'REGEXP', 'SCALAR' ],
       [
         { 0 => $RE{day_enum}, 1 => 'day' },
         [ [ 0 ] ],
         [ '_count_yearday' ],
       ],
    ],
    daytime => [
       [ 'REGEXP', 'SCALAR', 'SCALAR', 'SCALAR' ],
       [
         { 0 => $RE{number}, 1 => 'in', 2 => 'the', 3 => 'morning' },
         [ [ 0 ] ],
         [ '_daytime_in_the_morning' ],
       ],
       [
         { 0 => $RE{number}, 1 => 'in', 2 => 'the', 3 => 'afternoon' },
         [ [ 0 ] ],
         [ '_daytime_in_the_afternoon' ],
       ],
       [
         { 0 => $RE{number}, 1 => 'in', 2 => 'the', 3 => 'evening' },
         [ [ 0 ] ],
         [ '_daytime_in_the_evening' ],
       ],
    ],
    ago => [
       [ 'REGEXP', 'REGEXP', 'SCALAR' ],
       [
         { 0 => $RE{number}, 1 => qr/seconds?/i, 2 => 'ago' },
         [ [ 0 ] ],
         [ '_ago_seconds' ],
       ],
       [
         { 0 => $RE{number}, 1 => qr/minutes?/i, 2 => 'ago' },
         [ [ 0 ] ],
         [ '_ago_minutes' ],
       ],
       [
         { 0 => $RE{number}, 1 => qr/hours?/i, 2 => 'ago' },
         [ [ 0 ] ],
         [ '_ago_hours' ],
       ],
       [
         { 0 => $RE{number}, 1 => qr/days?/i, 2 => 'ago' },
         [ [ 0 ] ],
         [ '_ago_days' ],
       ],
       [
         { 0 => $RE{number}, 1 => qr/weeks?/i, 2 => 'ago' },
         [ [ 0 ] ],
         [ '_ago_weeks' ],
       ],
       [
         { 0 => $RE{number}, 1 => qr/months?/i, 2 => 'ago' },
         [ [ 0 ] ],
         [ '_ago_months' ],
       ],
       [
         { 0 => $RE{number}, 1 => qr/years?/i, 2 => 'ago' },
         [ [ 0 ] ],
         [ '_ago_years' ],
       ],
    ],
    ago_tomorrow => [
       [ 'SCALAR', 'REGEXP', 'REGEXP', 'SCALAR' ],
       [
         { 0 => 'tomorrow', 1 => $RE{number}, 2 => qr/seconds?/i, 3 => 'ago' },
         [ [], [ 1 ] ],
         [ '_day_tomorrow', '_ago_seconds' ],
       ],
       [
         { 0 => 'tomorrow', 1 => $RE{number}, 2 => qr/minutes?/i, 3 => 'ago' },
         [ [], [ 1 ] ],
         [ '_day_tomorrow', '_ago_minutes' ],
       ],
       [
         { 0 => 'tomorrow', 1 => $RE{number}, 2 => qr/hours?/i, 3 => 'ago' },
         [ [], [ 1 ] ],
         [ '_day_tomorrow', '_ago_hours' ],
       ],
       [
         { 0 => 'tomorrow', 1 => $RE{number}, 2 => qr/days?/i, 3 => 'ago' },
         [ [], [ 1 ] ],
         [ '_day_tomorrow', '_ago_days' ],
       ],
       [
         { 0 => 'tomorrow', 1 => $RE{number}, 2 => qr/weeks?/i, 3 => 'ago' },
         [ [], [ 1 ] ],
         [ '_day_tomorrow', '_ago_weeks' ],
       ],
       [
         { 0 => 'tomorrow', 1 => $RE{number}, 2 => qr/months?/i, 3 => 'ago' },
         [ [], [ 1 ] ],
         [ '_day_tomorrow', '_ago_months' ],
       ],
       [
         { 0 => 'tomorrow', 1 => $RE{number}, 2 => qr/years?/i, 3 => 'ago' },
         [ [], [ 1 ] ],
         [ '_day_tomorrow', '_ago_years' ],
       ],
    ],
    ago_yesterday => [
       [ 'REGEXP', 'REGEXP', 'REGEXP', 'SCALAR' ],
       [
         { 0 => 'yesterday', 1 => $RE{number}, 2 => qr/seconds?/i, 3 => 'ago' },
         [ [], [ 1 ] ],
         [ '_day_yesterday', '_ago_seconds' ],
       ],
       [
         { 0 => 'yesterday', 1 => $RE{number}, 2 => qr/minutes?/i, 3 => 'ago' },
         [ [], [ 1 ] ],
         [ '_day_yesterday', '_ago_minutes' ],
       ],
       [
         { 0 => 'yesterday', 1 => $RE{number}, 2 => qr/hours?/i, 3 => 'ago' },
         [ [], [ 1 ] ],
         [ '_day_yesterday', '_ago_hours' ],
       ],
       [
         { 0 => 'yesterday', 1 => $RE{number}, 2 => qr/days?/i, 3 => 'ago' },
         [ [], [ 1 ] ],
         [ '_day_yesterday', '_ago_days' ],
       ],
       [
         { 0 => 'yesterday', 1 => $RE{number}, 2 => qr/weeks?/i, 3 => 'ago' },
         [ [], [ 1 ] ],
         [ '_day_yesterday', '_ago_weeks' ],
       ],
       [
         { 0 => 'yesterday', 1 => $RE{number}, 2 => qr/months?/i, 3 => 'ago' },
         [ [], [ 1 ] ],
         [ '_day_yesterday', '_ago_months' ],
       ],
       [
         { 0 => 'yesterday', 1 => $RE{number}, 2 => qr/years?/i, 3 => 'ago' },
         [ [], [ 1 ] ],
         [ '_day_yesterday', '_ago_years' ],
       ],
    ],
    weekday_ago_at_time => [
       [ 'REGEXP', 'REGEXP', 'REGEXP', 'SCALAR', 'SCALAR', 'REGEXP' ],
       [
         { 0 => $RE{weekday}, 1 => $RE{number}, 2 => qr/months?/, 3 => 'ago', 4 => 'at', 5 => $RE{time_am} },
         [ [ 1 ], [ 0 ], [ 5 ] ],
         [ '_ago_months', '_weekday', '_time' ],
       ],
       [
         { 0 => $RE{weekday}, 1 => $RE{number}, 2 => qr/months?/, 3 => 'ago', 4 => 'at', 5 => $RE{time_pm} },
         [ [ 1 ], [ 0 ], [ 5 ] ],
         [ '_ago_months', '_weekday', '_at_pm' ],
       ],
    ],
    now_variant => [
       [ 'REGEXP', 'REGEXP', 'SCALAR', 'SCALAR' ],
       [
         { 0 => $RE{number}, 1 => qr/minutes?/i, 2 => 'before', 3 => 'now' },
         [ [ 0 ] ],
         [ '_now_minutes_before' ],
       ],
       [
         { 0 => $RE{number}, 1 => qr/minutes?/i, 2 => 'from', 3 => 'now' },
         [ [ 0 ] ],
         [ '_now_minutes_from' ],
       ],
       [
         { 0 => $RE{number}, 1 => qr/hours?/i, 2 => 'before', 3 => 'now' },
         [ [ 0 ] ],
         [ '_now_hours_before' ],
       ],
       [
         { 0 => $RE{number}, 1 => qr/hours?/i, 2 => 'from', 3 => 'now' },
         [ [ 0 ] ],
         [ '_now_hours_from' ],
       ],
       [
         { 0 => $RE{number}, 1 => qr/days?/i,  2 => 'before', 3 => 'now' },
         [ [ 0 ] ],
         [ '_now_days_before' ],
       ],
       [
         { 0 => $RE{number}, 1 => qr/days?/i, 2 => 'from', 3 => 'now' },
         [ [ 0 ] ],
         [ '_now_days_from' ],
       ],
       [
         { 0 => $RE{number}, 1 => qr/weeks?/i, 2 => 'before', 3 => 'now' },
         [ [ 0 ] ],
         [ '_now_weeks_before' ],
       ],
       [
         { 0 => $RE{number}, 1 => qr/weeks?/i, 2 => 'from', 3 => 'now' },
         [ [ 0 ] ],
         [ '_now_weeks_from' ],
       ],
       [
         { 0 => $RE{number}, 1 => qr/months?/i, 2 => 'before', 3 => 'now' },
         [ [ 0 ] ],
         [ '_now_months_before' ],
       ],
       [
         { 0 => $RE{number}, 1 => qr/months?/i, 2 => 'from', 3 => 'now' },
         [ [ 0 ] ],
         [ '_now_months_from' ],
       ],
       [
         { 0 => $RE{number}, 1 => qr/years?/i, 2 => 'before', 3 => 'now' },
         [ [ 0 ] ],
         [ '_now_years_before' ],
       ],
       [
         { 0 => $RE{number}, 1 => qr/years?/i, 2 => 'from', 3 => 'now' },
         [ [ 0 ] ],
         [ '_now_years_from' ],
       ],
    ],
    day_daytime => [
       [ 'REGEXP', 'REGEXP', 'SCALAR', 'SCALAR', 'SCALAR' ],
       [
         { 0 => $RE{weekday}, 1 => $RE{number}, 2 => 'in', 3 => 'the', 4 => 'morning' },
         [ [ 0 ], [ 1 ] ],
         [ '_weekday', '_daytime_in_the_morning' ],
       ],
       [
         { 0 => $RE{weekday}, 1 => $RE{number}, 2 => 'in', 3 => 'the', 4 => 'afternoon' },
         [ [ 0 ], [ 1 ] ],
         [ '_weekday', '_daytime_in_the_afternoon' ],
       ],
       [
         { 0 => $RE{weekday}, 1 => $RE{number}, 2 => 'in', 3 => 'the', 4 => 'evening' },
         [ [ 0 ], [ 1 ] ],
         [ '_weekday', '_daytime_in_the_evening' ],
       ],
    ],

    last_day_at_time => [
       [ 'SCALAR', 'REGEXP', 'SCALAR', 'REGEXP' ],
       [
         { 0 => 'last', 1 => $RE{weekday}, 2 => 'at', 3 => $RE{time} },
         [ [ 1 ], [ 3 ] ],
         [ '_last_day', '_time' ],
       ],
    ],
    last_week_day => [
       [ 'SCALAR', 'SCALAR', 'REGEXP' ],
       [
         { 0 => 'last', 1 => 'week', 2 => $RE{weekday} },
         [ [ 2 ] ],
         [ '_last_week_day' ],
       ],
    ],
    day_last_week => [
       [ 'REGEXP', 'SCALAR', 'SCALAR' ],
       [
         { 0 => $RE{weekday}, 1 => 'last', 2 => 'week' },
         [ [ 0 ] ],
         [ '_day_last_week' ],
       ],
    ],
    count_day_last_week => [
       [ 'REGEXP', 'SCALAR', 'SCALAR', 'SCALAR' ],
       [
         { 0 => $RE{day_enum}, 1 => 'day', 2 => 'last', 3 => 'week' },
         [ [ 0 ] ],
         [ '_count_day_last_week' ],
       ],
    ],
    count_day_last_month => [
       [ 'REGEXP', 'SCALAR', 'SCALAR', 'SCALAR' ],
       [
         { 0 => $RE{day_enum}, 1 => 'day', 2 => 'last', 3 => 'month' },
         [ [ 0 ] ],
         [ '_count_day_last_month' ],
       ],
    ],

    weekday_next_week => [
       [ 'REGEXP', 'SCALAR', 'SCALAR' ],
       [
         { 0 => $RE{weekday}, 1 => 'next', 2 => 'week' },
         [ [ 0 ] ],
         [ '_weekday_next_week' ],
       ],
    ],
    count_day_next_month => [
       [ 'REGEXP', 'SCALAR', 'SCALAR', 'SCALAR' ],
       [
         { 0 => $RE{day_enum}, 1 => 'day', 2 => 'next', 3 => 'month' },
         [ [ 0 ] ],
         [ '_count_day_next_month' ],
       ],
    ],
    count_month_next_year => [
       [ 'REGEXP', 'SCALAR', 'SCALAR', 'SCALAR' ],
       [
         { 0 => $RE{day_enum}, 1 => 'month', 2 => 'next', 3 => 'year' },
         [ [ 0 ] ],
         [ '_count_month_next_year' ],
       ],
    ],
    in_count_minutes => [
       [ 'SCALAR', 'REGEXP', 'SCALAR' ],
       [
         { 0 => 'in', 1 => $RE{number}, 2 => qr/minutes?/i },
         [ [ 1 ] ],
         [ '_in_count_minutes' ],
       ]
    ],
    in_count_hours => [
       [ 'SCALAR', 'REGEXP', 'SCALAR' ],
       [
         { 0 => 'in', 1 => $RE{number}, 2 => 'hours' },
         [ [ 1 ] ],
         [ '_in_count_hours' ],
       ],
    ],
    in_count_days => [
       [ 'SCALAR', 'REGEXP', 'SCALAR' ],
       [
         { 0 => 'in', 1 => $RE{number}, 2 => qr/days?/i },
         [ [ 1 ] ],
         [ '_in_count_days' ],
       ],
    ],
    weekday_this_week => [
       [ 'REGEXP', 'SCALAR', 'SCALAR' ],
       [
         { 0 => $RE{weekday}, 1 => 'this', 2 => 'week' },
         [ [ 0 ] ],
         [ '_weekday_this_week' ],
       ],
    ],
    count_weekday_this_month => [
       [ 'REGEXP', 'REGEXP', 'SCALAR', 'REGEXP' ],
       [
         { 0 => $RE{day_enum}, 1 => $RE{weekday}, 2 => 'this', 3 => $RE{month} },
         [ [ 0, 1, 3 ] ],
         [ '_count_weekday_this_month' ],
       ],
    ],
    day_variant => [
       [ 'REGEXP', 'REGEXP', 'SCALAR', 'SCALAR' ],
       [
         { 0 => $RE{number}, 1 => qr/hours?/i, 2 => 'before', 3 => 'yesterday' },
         [ [ 0 ] ],
         [ '_daytime_variant_before_yesterday' ],
       ],
       [
         { 0 => $RE{number}, 1 => qr/hours?/i, 2 => 'before', 3 => 'tomorrow' },
         [ [ 0 ] ],
         [ '_daytime_variant_before_tomorrow' ],
       ],
       [
         { 0 => $RE{number}, 1 => qr/hours?/i, 2 => 'after', 3 => 'yesterday' },
         [ [ 0 ] ],
         [ '_daytime_variant_after_yesterday' ],
       ],
       [
         { 0 => $RE{number}, 1 => qr/hours?/i, 2 => 'after', 3 => 'tomorrow' },
         [ [ 0 ] ],
         [ '_daytime_variant_after_tomorrow' ],
       ],
    ],
    hourtime => [
       [ 'REGEXP', 'REGEXP', 'SCALAR', 'SCALAR' ],
       [
         { 0 => $RE{number}, 1 => qr/hours?/i, 2 => 'before', 3 => 'noon' },
         [ [ 0 ] ],
         [ '_hourtime_before_noon' ],
       ],
       [
         { 0 => $RE{number}, 1 => qr/hours?/i, 2 => 'after', 3 => 'noon' },
         [ [ 0 ] ],
         [ '_hourtime_after_noon' ],
       ],
       [
         { 0 => $RE{number}, 1 => qr/hours?/i, 2 => 'before', 3 => 'midnight' },
         [ [ 0 ] ],
         [ '_hourtime_before_midnight' ],
       ],
       [
         { 0 => $RE{number}, 1 => qr/hours?/i, 2 => 'after', 3 => 'midnight' },
         [ [ 0 ] ],
         [ '_hourtime_after_midnight' ],
       ],
    ],
    day_at => [
       [ 'SCALAR', 'SCALAR', 'REGEXP' ],
       [
         { 0 => 'yesterday', 1 => 'at', 2 => $RE{time_am} },
         [ [], [ 2 ] ],
         [ '_day_yesterday', '_time' ],
       ],
       [
         { 0 => 'today', 1 => 'at', 2 => $RE{time_am} },
         [ [], [ 2 ] ],
         [ '_day_today', '_time' ],
       ],
       [
         { 0 => 'tomorrow', 1 => 'at', 2 => $RE{time_am} },
         [ [], [ 2 ] ],
         [ '_day_tomorrow', '_time' ],
       ],
    ],
    weekday_at_time => [
       [ 'REGEXP', 'SCALAR', 'REGEXP' ],
       [
         { 0 => $RE{weekday}, 1 => 'at', 2 => $RE{time_am} },
         [ [ 0 ], [ 2 ] ],
         [ '_weekday', '_time' ],
       ],
    ],
    day_at_pm => [
       [ 'SCALAR', 'SCALAR', 'REGEXP' ],
       [
         { 0 => 'yesterday', 1 => 'at', 2 => $RE{time_pm} },
         [ [], [ 2 ] ],
         [ '_day_yesterday', '_at_pm' ],
       ],
       [
         { 0 => 'today', 1 => 'at', 2 => $RE{time_pm} },
         [ [], [ 2 ] ],
         [ '_day_today', '_at_pm' ],
       ],
       [
         { 0 => 'tomorrow', 1 => 'at', 2 => $RE{time_pm} },
         [ [], [ 2 ] ],
         [ '_day_tomorrow', '_at_pm' ],
       ],
    ],
    weekday_at_time_pm => [
       [ 'REGEXP', 'SCALAR', 'REGEXP' ],
       [
         { 0 => $RE{weekday}, 1 => 'at', 2 => $RE{time_pm} },
         [ [ 0 ], [ 2 ] ],
         [ '_weekday', '_at_pm' ],
       ],
    ],
    day_month_year => [
       [ 'REGEXP', 'REGEXP', 'REGEXP' ],
       [
         { 0 => $RE{monthday}, 1 => $RE{month}, 2 => $RE{year} },
         [ [ 0, 1, 2 ] ],
         [ '_day_month_year' ],
       ],
       [
         { 0 => $RE{month}, 1 => $RE{monthday}, 2 => $RE{year} },
         [ [ 1, 0, 2 ] ],
         [ '_day_month_year' ],
       ],
    ],
    count_weekday_in_month => [
       [ 'REGEXP', 'REGEXP', 'SCALAR', 'REGEXP' ],
       [
         { 0 => $RE{day_enum}, 1 => $RE{weekday}, 2 => 'in', 3 => $RE{month} },
         [ [ 0, 1, 3 ] ],
         [ '_count_weekday_this_month' ],
       ],
    ],
);

1;
__END__

=head1 NAME

DateTime::Format::Natural::Lang::EN - English language metadata

=head1 DESCRIPTION

C<DateTime::Format::Natural::Lang::EN> provides the english specific grammar
and variables. This class is loaded if the user either specifies the english 
language or implicitly.

=head1 EXAMPLES

Below are some examples of human readable date/time input in english (be aware
that the parser does not distinguish between lower/upper case):

=head2 Simple

 now
 today
 yesterday
 tomorrow
 morning
 afternoon
 evening
 noon
 midnight
 this morning
 this afternoon
 this evening
 yesterday morning
 yesterday afternoon
 yesterday evening
 today morning
 today afternoon
 today evening
 tomorrow morning
 tomorrow afternoon
 tomorrow evening
 march
 4th february
 november 3rd 
 saturday
 last wednesday
 last june
 last month
 last year
 next friday
 next october
 next month
 next year
 this thursday
 this month
 6 am
 5am
 5am yesterday
 5am today
 5am tomorrow
 8 pm
 4pm
 4pm yesterday
 4pm today
 4pm tomorrow
 sunday 11:00
 mon 2:35
 13:45
 may 2002
 2nd monday
 100th day
 6 in the morning
 sat 7 in the evening
 this second
 yesterday at 4:00
 last january
 last friday at 20:00
 tomorrow at 6:45pm
 yesterday afternoon
 thursday last week

=head2 Complex

 6 in the morning
 4 in the afternoon
 9 in the evening
 25 seconds ago
 10 minutes ago
 7 hours ago
 40 days ago
 2 weeks ago
 5 months ago
 3 years ago
 tomorrow 25 seconds ago
 tomorrow 10 minutes ago
 tomorrow 7 hours ago
 tomorrow 40 day ago
 tomorrow 2 weeks ago
 tomorrow 5 months ago
 tomorrow 3 years ago
 yesterday 25 seconds ago
 yesterday 10 minutes ago
 yesterday 7 hours ago
 yesterday 40 days ago
 yesterday 2 weeks ago
 yesterday 5 months ago
 yesterday 3 years ago
 fri 3 months ago at 5am
 wednesday 1 month ago at 8pm
 8 hours before now
 8 hours from now
 7 days before now
 7 days from now
 4 weeks before now
 4 weeks from now
 13 months before now
 13 months from now
 2 years before now
 2 years from now
 tuesday 4 in the morning
 thursday 2 in the afternoon
 monday 6 in the evening
 last sunday at 21:45
 last week friday
 monday last week
 2nd day last week
 10th day last month
 tuesday next week
 3rd day next month
 10th month next year
 in 42 minutes
 in 3 hours
 in 5 days
 wednesday this week
 3rd tuesday this november
 3 hours before tomorrow
 6 hours before yesterday
 9 hours after tomorrow
 12 hours after yesterday
 3 hours before noon
 6 hours after noon
 9 hours before midnight
 12 hours after midnight
 yesterday at noon
 yesterday at midnight
 today at noon
 today at midnight
 tomorrow at noon
 tomorrow at midnight
 yesterday at 16:00
 today at 6:00
 tomorrow at 12
 wednesday at 14:30
 2nd friday in august
 tomorrow 1 year ago
 saturday 3 months ago at 5:00pm
 4th day last week
 3rd wednesday in november
 3rd month next year

=head2 Timespans

 Monday to Friday
 1 April to 31 August

=head2 Specific Dates

 January 11
 11 January
 dec 25
 may 27th
 October 2006
 february 14, 2004
 Friday
 jan 3 2010
 3 jan 2000
 27/5/1979
 4:00
 17:00

=head1 SEE ALSO

L<DateTime::Format::Natural>

=head1 AUTHOR

Steven Schubiger <schubiger@cpan.org>

=head1 LICENSE

This program is free software; you may redistribute it and/or
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
