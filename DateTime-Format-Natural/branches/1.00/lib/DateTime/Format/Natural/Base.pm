package DateTime::Format::Natural::Base;

use strict;
use warnings;

use DateTime ();
use Date::Calc qw(Add_Delta_Days
                  Decode_Day_of_Week
                  Nth_Weekday_of_Month_Year
                  check_date check_time);

our $VERSION = '1.07';

use constant MORNING   => '08';
use constant AFTERNOON => '14';
use constant EVENING   => '20'; 

sub _ago_seconds 
{
    my $self = shift;
    $self->_add_trace;
    $self->_subtract(second => shift);
    $self->_set_modified(3);
}

sub _ago_minutes 
{
    my $self = shift;
    $self->_add_trace;
    $self->_subtract(minute => shift);
    $self->_set_modified(3);
}

sub _ago_hours 
{
    my $self = shift;
    $self->_add_trace;
    $self->_subtract(hour => shift);
    $self->_set_modified(3);
}

sub _ago_days 
{
    my $self = shift;
    $self->_add_trace;
    $self->_subtract(day => shift);
    $self->_set_modified(3);
}

sub _ago_weeks 
{
    my $self = shift;
    $self->_add_trace;
    $self->_subtract(week => shift);
    $self->_set_modified(3);
}

sub _ago_months 
{
    my $self = shift;
    $self->_add_trace;
    $self->_subtract(month => shift);
    $self->_set_modified(3);
}

sub _ago_years 
{
    my $self = shift;
    $self->_add_trace;
    $self->_subtract(year => shift);
    $self->_set_modified(3);
}

sub _now_minutes_before
{
    my $self = shift;
    $self->_add_trace;
    $self->_subtract(minute => shift);
    $self->_set_modified(4);
}

sub _now_minutes_from
{
    my $self = shift;
    $self->_add_trace;
    $self->_add(minute => shift);
    $self->_set_modified(4);
}

sub _now_hours_before
{
    my $self = shift;
    $self->_add_trace;
    $self->_subtract(hour => shift);
    $self->_set_modified(4);
}

sub _now_hours_from
{
    my $self = shift;
    $self->_add_trace;
    $self->_add(hour => shift);
    $self->_set_modified(4);
}

sub _now_days_before 
{
    my $self = shift;
    $self->_add_trace;
    $self->_subtract(day => shift);
    $self->_set_modified(4);
}

sub _now_days_from 
{
    my $self = shift;
    $self->_add_trace;
    $self->_add(day => shift);
    $self->_set_modified(4);
}

sub _now_weeks_before 
{
    my $self = shift;
    $self->_add_trace;
    $self->_subtract(day => (7 * shift));
    $self->_set_modified(4);
}

sub _now_weeks_from 
{
    my $self = shift;
    $self->_add_trace;
    $self->_add(day => (7 * shift));
    $self->_set_modified(4);
}

sub _now_months_before 
{
    my $self = shift;
    $self->_add_trace;
    $self->_subtract(month => shift);
    $self->_set_modified(4);
}

sub _now_months_from
{
    my $self = shift;
    $self->_add_trace;
    $self->_add(month => shift);
    $self->_set_modified(4);
}

sub _now_years_before 
{
    my $self = shift;
    $self->_add_trace;
    $self->_subtract(year => shift);
    $self->_set_modified(4);
}

sub _now_years_from 
{
    my $self = shift;
    $self->_add_trace;
    $self->_add(year => shift);
    $self->_set_modified(4);
}

sub _daytime_in_the_morning 
{
    my $self = shift;
    $self->_add_trace;
    my ($hour) = @_;
    if ($self->_valid_time(hour => $hour + 12)) {
        $self->_set(hour => $hour);
        $self->_set(minute => 0);
        $self->_set(second => 0);
    }
    $self->_set_modified(4);
}

sub _daytime_in_the_afternoon
{
    my $self = shift;
    $self->_add_trace;
    my ($hour) = @_;
    if ($self->_valid_time(hour => 12 + $hour)) {
        $self->_set(hour => 12 + $hour);
        $self->_set(minute => 0);
        $self->_set(second => 0);
    }
    $self->_set_modified(4);
}

sub _daytime_in_the_evening
{
    my $self = shift;
    $self->_add_trace;
    my ($hour) = @_;
    if ($self->_valid_time(hour => 12 + $hour)) {
        $self->_set(hour => 12 + $hour);
        $self->_set(minute => 0);
        $self->_set(second => 0);
    }
    $self->_set_modified(4);
}

sub _daytime_morning 
{
    my $self = shift;
    $self->_add_trace;
    my $hour = $self->{Opts}{daytime}{morning}
      ? $self->{Opts}{daytime}{morning}
      : MORNING;
    if ($self->_valid_time(hour => $hour)) {
        $self->_set(hour => $hour);
        $self->_set(minute => 0);
        $self->_set(second => 0);
    }
    $self->_set_modified(1);
}

sub _daytime_noon
{
    my $self = shift;
    $self->_add_trace;
    $self->_set(hour => 12);
    $self->_set(minute => 0);
    $self->_set(second => 0);
    $self->_set_modified(1);
}

sub _daytime_afternoon 
{
    my $self = shift;
    $self->_add_trace;
    my $hour = $self->{Opts}{daytime}{afternoon}
      ? $self->{Opts}{daytime}{afternoon}
      : AFTERNOON;
    if ($self->_valid_time(hour => $hour)) {
        $self->_set(hour => $hour);
        $self->_set(minute => 0);
        $self->_set(second => 0);
    }
    $self->_set_modified(1);
}

sub _daytime_evening
{
    my $self = shift;
    $self->_add_trace;
    my $hour = $self->{Opts}{daytime}{evening}
      ? $self->{Opts}{daytime}{evening}
      : EVENING;
    if ($self->_valid_time(hour => $hour)) {
        $self->_set(hour => $hour);
        $self->_set(minute => 0);
        $self->_set(second => 0);
    }
    $self->_set_modified(1);
}

sub _daytime_midnight
{
    my $self = shift;
    $self->_add_trace;
    $self->_set(hour => 0);
    $self->_set(minute => 0);
    $self->_set(second => 0);
    $self->_set_modified(2);
}

sub _hourtime_before_noon
{
    my $self = shift;
    $self->_add_trace;
    $self->_set(hour => 12);
    $self->_set(minute => 0);
    $self->_subtract(hour => shift);
    $self->_set_modified(4);
}

sub _hourtime_after_noon
{
    my $self = shift;
    $self->_add_trace;
    $self->_set(hour => 12);
    $self->_set(minute => 0);
    $self->_add(hour => shift);
    $self->_set_modified(4);
}

sub _hourtime_before_midnight
{
    my $self = shift;
    $self->_add_trace;
    $self->_set(hour => 0);
    $self->_set(minute => 0);
    $self->_subtract(hour => shift);
    $self->_set_modified(4);
}

sub _hourtime_after_midnight
{
    my $self = shift;
    $self->_add_trace;
    $self->_set(hour => 0);
    $self->_set(minute => 0);
    $self->_add(hour => shift);
    $self->_set_modified(4);
}

sub _day
{
    my $self = shift;
    $self->_add_trace;
    my ($day) = @_;
    if ($self->_valid_date(day => $day)) {
        $self->_set(day => $day);
    }
    $self->_set_modified(1);
}

sub _day_today
{
    my $self = shift;
    $self->_set_modified(1);
}

sub _day_yesterday
{
    my $self = shift;
    $self->_subtract(day => 1);
    $self->_set_modified(1);
}

sub _day_tomorrow
{
    my $self = shift;
    $self->_add(day => 1);
    $self->_set_modified(1);
}

sub _month 
{
    my $self = shift;
    $self->_add_trace;
    my ($month) = @_;
    $month = ucfirst lc $month;
    if (length $month == 3) {
        $month = $self->{data}->{months_abbrev}->{$month};
    }
    $self->_set(month => $self->{data}->{months}->{$month});
    $self->_set_modified(1);    
}

sub _month_day_after
{
    my $self = shift;
    $self->_add_trace;
    my ($month, $day) = @_;
    $month = ucfirst lc $month;
    if (length $month == 3) {
        $month = $self->{data}->{months_abbrev}->{$month};
    }
    $self->_set(month => $self->{data}->{months}->{$month});
    if ($self->_valid_date(day => $day)) {
        $self->_set(day => $day);
    }
    $self->_set_modified(2);
}

sub _month_day_before
{
    my $self = shift;
    $self->_add_trace;
    my ($day, $month) = @_;
    $month = ucfirst lc $month;
    if (length $month == 3) {
        $month = $self->{data}->{months_abbrev}->{$month};
    }
    $self->_set(month => $self->{data}->{months}->{$month});
    if ($self->_valid_date(day => $day)) {
        $self->_set(day => $day);
    }
    $self->_set_modified(2);
}

sub _year
{
    my $self = shift;
    $self->_add_trace;
    my ($year) = @_;
    if ($self->_valid_date(year => $year)) {
        $self->_set(year => $year);
    }
    $self->_set_modified(1);
}

sub _weekday
{
    my $self = shift;
    $self->_add_trace;    
    my ($day) = @_;
    $day = ucfirst lc $day;
    if (length $day == 3) {
        $day = $self->{data}->{weekdays_abbrev}->{$day};
    }
    my $days_diff;
    # Set current weekday by adding the day difference
    if ($self->{data}->{weekdays}->{$day} > $self->{datetime}->wday) {
        $days_diff = $self->{data}->{weekdays}->{$day} - $self->{datetime}->wday;
        $self->_add(day => $days_diff);
    } 
    # Set current weekday by subtracting the difference
    else {
        $days_diff = $self->{datetime}->wday - $self->{data}->{weekdays}->{$day};
        $self->_subtract(day => $days_diff);
    }
    $self->_set_modified(1);
}

sub _last_day 
{
    my $self = shift;
    $self->_add_trace;
    my ($day) = @_;
    $day = ucfirst lc $day;
    if (length $day == 3) {
        $day = $self->{data}->{weekdays_abbrev}->{$day};
    }
    my $days_diff = $self->{datetime}->wday + (7 - $self->{data}->{weekdays}->{$day});
    $self->_subtract(day => $days_diff);
    $self->_set_modified(2);
}

sub _last_week_day
{
    my $self = shift;
    $self->_add_trace;
    my $day = ucfirst lc(shift);
    my $days_diff = $self->{datetime}->wday + (7 - $self->{data}->{weekdays}->{$day});
    $self->_subtract(day => $days_diff);
    $self->_set_modified(3);
}

sub _day_last_week
{
    my $self = shift;
    $self->_add_trace;
    my $day = ucfirst lc(shift);
    my $days_diff = $self->{datetime}->wday + (7 - $self->{data}->{weekdays}->{$day});
    $self->_subtract(day => $days_diff);
    $self->_set_modified(3);
}

sub _count_day_last_week
{
    my $self = shift;
    $self->_add_trace;    
    my ($day) = @_;
    my $days_diff = (7 + $self->{datetime}->wday);
    $self->_subtract(day => $days_diff);
    $self->_add(day => $day);
    $self->_set_modified(4);
}

sub _last_week
{
    my $self = shift;
    $self->_add_trace;
    $self->_subtract(day => 7);
    $self->_set_modified(2);
}

sub _last_month
{
    my $self = shift;
    $self->_add_trace;
    my ($month) = @_;
    $month = ucfirst lc $month;
    if (length $month == 3) {
        $month = $self->{data}->{months_abbrev}->{$month};
    }
    $self->_subtract(year => 1);
    $self->_set(month => $self->{data}->{months}->{$month});
    $self->_set_modified(4);
}

sub _last_month_literal
{
    my $self = shift;
    $self->_add_trace;
    $self->_subtract(month => 1);
    $self->_set_modified(2);
}

sub _count_day_last_month
{
    my $self = shift;
    $self->_add_trace;
    my ($day) = @_;
    $self->_subtract(month => 1);
    $self->_set(day => $day);
    $self->_set_modified(4);
}

sub _last_year
{
    my $self = shift;
    $self->_add_trace;
    $self->_subtract(year => 1);
    $self->_set_modified(2);
}

sub _next_weekday
{
    my $self = shift;
    $self->_add_trace;
    my ($day) = @_;
    $day = ucfirst lc $day;
    if (length $day == 3) {
        $day = $self->{data}->{weekdays_abbrev}->{$day};
    }
    my $days_diff = (7 - $self->{datetime}->wday + Decode_Day_of_Week($day));
    $self->_add(day => $days_diff);
    $self->_set_modified(2);
}

sub _weekday_next_week
{
    my $self = shift;
    $self->_add_trace;
    my ($day) = @_;
    $day = ucfirst lc $day;
    if (length $day == 3) {
        $day = $self->{data}->{weekdays_abbrev}->{$day};
    }            
    my $days_diff = (7 - $self->{datetime}->wday + Decode_Day_of_Week($day));
    $self->_add(day => $days_diff);
    $self->_set_modified(3);
}

sub _next_month
{
    my $self = shift;
    $self->_add_trace;
    my ($month) = @_;
    $month = ucfirst lc $month;
    if (length $month == 3) {
        $month = $self->{data}->{months_abbrev}->{$month};
    }
    $self->_add(year => 1);
    $self->_set(month => $self->{data}->{months}->{$month});
    $self->_set_modified(2);
}

sub _next_month_literal
{
    my $self = shift;
    $self->_add_trace;
    $self->_add(month => 1);
    $self->_set_modified(2);
}

sub _count_day_next_month
{           
    my $self = shift;
    $self->_add_trace;
    my ($day) = @_;
    $self->_add(month => 1);
    $self->_set(day => $day);
    $self->_set_modified(4);
}

sub _next_year
{
    my $self = shift;
    $self->_add_trace;
    $self->_add(year => 1);
    $self->_set_modified(2);
}

sub _count_month_next_year
{
    my $self = shift;
    $self->_add_trace;
    my ($month) = @_;
    $self->_add(year => 1);
    $self->_set(month => $month);
    $self->_set_modified(4);
}

sub _in_count_minutes
{
    my $self = shift;
    $self->_add_trace;
    my ($minute) = @_;
    $self->_add(minute => $minute);
    $self->_set_modified(3);
}

sub _in_count_hours
{
    my $self = shift;
    $self->_add_trace;
    my ($hour) = @_;
    $self->_add(hour => $hour);
    $self->_set_modified(3);
}

sub _in_count_days
{
    my $self = shift;
    $self->_add_trace;
    my ($day) = @_;
    $self->_add(day => $day);
    $self->_set_modified(3);
}

sub _this_second
{
    my $self = shift;
    $self->_add_trace;
    $self->_set_modified(2);
}

sub _this_weekday
{
    my $self = shift;
    $self->_add_trace;
    my ($day) = @_;
    $day = ucfirst lc $day;
    if (length $day == 3) {
        $day = $self->{data}->{weekdays_abbrev}->{$day};
    }              
    my $days_diff = $self->{data}->{weekdays}->{$day} - $self->{datetime}->wday;
    $self->_add(day => $days_diff);
    $self->_set_modified(2);
}

sub _weekday_this_week
{
    my $self = shift;
    $self->_add_trace;  
    my ($day) = @_;
    $day = ucfirst lc $day;
    my $days_diff = Decode_Day_of_Week($day) - $self->{datetime}->wday;
    $self->_add(day => $days_diff);
    $self->_set_modified(3);
}

sub _this_month
{
    my $self = shift;
    $self->_add_trace;
    $self->_set_modified(2);
}

sub _count_weekday_this_month
{
    my $self = shift;
    my ($count, $day, $month) = @_;
    $self->_add_trace;
    $day = ucfirst lc $day;
    if (length $day == 3) {
        $day = $self->{data}->{weekdays_abbrev}->{$day};
    }
    $month = ucfirst lc $month;
    if (length $month == 3) {
        $month = $self->{data}->{months_abbrev}->{$month};
    }
    my $year;
    ($year, $month, $day) = 
      Nth_Weekday_of_Month_Year($self->{datetime}->year, 
                                $self->{data}->{months}->{$month}, 
                                $self->{data}->{weekdays}->{$day}, 
                                $count);
    $self->_set(year => $year);
    $self->_set(month => $month);
    $self->_set(day => $day);
    $self->_set_modified(4);
}

sub _daytime_variant_before_yesterday
{
    my $self = shift;
    $self->_add_trace;
    $self->_subtract(day => 2);
    $self->_set(hour => (24 - shift));
    $self->_set_modified(4);
}

sub _daytime_variant_after_yesterday
{
    my $self = shift;
    $self->_add_trace;
    $self->_subtract(day => 1);
    $self->_set(hour => (0 + shift));
    $self->_set_modified(4);
}

sub _daytime_variant_before_tomorrow
{
    my $self = shift;
    $self->_add_trace;
    $self->_set(hour => (24 - shift));
    $self->_set_modified(4);
}

sub _daytime_variant_after_tomorrow
{
    my $self = shift;
    $self->_add_trace;
    $self->_add(day => 1);
    $self->_set(hour => (0 + shift));
    $self->_set_modified(4);
}

sub _at_am
{
    my $self = shift;
    $self->_add_trace;
    my ($time) = @_;
    if ($time =~ /:/) {
        my ($hour, $minute) = split /:/, $time;
        if ($self->_valid_time(hour => $hour, minute => $minute)) {
            $self->_set(hour => $hour);
            $self->_set(minute => $minute);
        }
    }
    else {
        if ($self->_valid_time(hour => $time)) {
	    $self->_set(hour => $time);
            $self->_set(minute => 0);
        }
    }
    $self->_set_modified(2);
}

sub _at_pm
{
    my $self = shift;
    $self->_add_trace;
    my ($time) = @_;
    if ($time =~ /:/) {
        my ($hour, $minute) = split /:/, $time; 
        if ($self->_valid_time(hour => 12 + $hour, minute => $minute)) {      
            $self->_set(hour => 12 + $hour);
            $self->_set(minute => $minute);
        }
    }
    else {
        if ($self->_valid_time(hour => 12 + $time)) {
	    $self->_set(hour => 12 + $time);
            $self->_set(minute => 0);
        }
    }
    $self->_set_modified(2);
}

sub _time
{
    my $self = shift;
    $self->_add_trace;
    my ($time) = @_;
    if ($time =~ /:/) {
        my ($hour, $minute) = split /:/, $time;
        if ($self->_valid_time(hour => $hour, minute => $minute)) {
            $self->_set(hour => $hour);
            $self->_set(minute => $minute);
        }
    }
    else {
        if ($self->_valid_time(hour => $time)) {
	    $self->_set(hour => $time);
            $self->_set(minute => 0);
        }
    }
    $self->_set_modified(1);
}

sub _today
{
    my $self = shift;
    $self->_add_trace;
    $self->_set_modified(1);
}

sub _count_yearday
{
    my $self = shift;
    $self->_add_trace;   
    my ($day) = @_;
    my ($year, $month);
    ($year, $month, $day) = Add_Delta_Days($self->{datetime}->year, 1, 1, $day - 1);
    $self->_set(day => $day);
    $self->{datetime}->set_month($month);
    $self->{datetime}->set_year($year);
    $self->_set_modified(2);
}

sub _count_weekday 
{
    my $self = shift;
    $self->_add_trace;
    my ($count, $weekday) = @_;
    $weekday = ucfirst lc $weekday;
    my ($year, $month, $day) = 
      Nth_Weekday_of_Month_Year($self->{datetime}->year, 
                                $self->{datetime}->month,
                                $self->{data}->{weekdays}->{$weekday},
                                $count);
    if ($self->_valid_date(day => $day, month => $month, year => $year)) {
        $self->_set(day => $day);
        $self->_set(month => $month);
        $self->{datetime}->set_year($year);
    }
    $self->_set_modified(2);
}

sub _add 
{
    my ($self, $unit, $value) = @_;

    $self->{modified}{$unit}++;

    $unit .= 's' unless $unit =~ /s$/;
    $self->{datetime}->add($unit => $value);
}

sub _subtract 
{
    my ($self, $unit, $value) = @_;

    $self->{modified}{$unit}++;

    $unit .= 's' unless $unit =~ /s$/;
    $self->{datetime}->subtract($unit => $value);
}

sub _set 
{
    my ($self, $unit, $value) = @_;

    $self->{modified}{$unit}++;

    my $setter = 'set_' . $unit;
    $self->{datetime}->$setter($value);
}

sub _valid_date 
{
    my ($self, $type, $value) = @_;

    my %set = map { $_ => $self->{datetime}->$_ } qw(year month day);
    $set{$type} = $value;

    if (check_date($set{year}, $set{month}, $set{day})) {
        return 1;
    } 
    else {
        $self->_set_failure;
        $self->_set_error("('$value' is not a valid $type)");
        return 0;
    }
}

sub _valid_time 
{
    my ($self, $type, $value) = @_;

    my %set = map { $_ => $self->{datetime}->$_ } qw(hour min sec);
    $set{$type} = $value;

    if (check_time($set{hour}, $set{min}, $set{sec})) {
        return 1;
    } 
    else {
        $self->_set_failure;
        $self->_set_error("('$value' is not a valid $type)");
        return 0;
    }
}

1;
__END__

=head1 NAME

DateTime::Format::Natural::Base - Base class for DateTime::Format::Natural

=head1 SYNOPSIS

 Please see the DateTime::Format::Natural documentation.

=head1 DESCRIPTION

The C<DateTime::Format::Natural::Base> module defines the core functionality of
C<DateTime::Format::Natural>.

=head1 SEE ALSO

L<DateTime::Format::Natural>

=head1 AUTHOR

Steven Schubiger <schubiger@cpan.org>

=head1 LICENSE

This program is free software; you may redistribute it and/or
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
