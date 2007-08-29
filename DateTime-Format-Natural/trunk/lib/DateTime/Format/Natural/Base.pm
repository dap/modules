package DateTime::Format::Natural::Base;

use strict;
use warnings;

use DateTime;
use Date::Calc qw(Add_Delta_Days Days_in_Month
                  Decode_Day_of_Week
                  Nth_Weekday_of_Month_Year
                  check_date check_time);
use List::MoreUtils qw(all any none);

our $VERSION = '1.01';

use constant {
    MORNING   => '08',
    AFTERNOON => '14',
    EVENING   => '20',
};

sub _ago {
    my $self = shift;

    $self->_add_trace;

    my @new_tokens = splice(@{$self->{tokens}}, $self->{index}, 3);

    # seconds ago
    if ($new_tokens[1] =~ $self->{data}->__ago('second')) {
        $self->_subtract(second => $new_tokens[0]);
        $self->_set_modified(3);
    } 
    # minutes ago
    elsif ($new_tokens[1] =~ $self->{data}->__ago('minute')) {
        $self->_subtract(minute => $new_tokens[0]);
        $self->_set_modified(3);
    } 
    # hours ago
    elsif ($new_tokens[1] =~ $self->{data}->__ago('hour')) {
        $self->_subtract(hour => $new_tokens[0]);
        $self->_set_modified(3);
    } 
    # days ago
    elsif ($new_tokens[1] =~ $self->{data}->__ago('day')) {
        $self->_subtract(day => $new_tokens[0]);
        $self->_set_modified(3);
    } 
    # weeks ago
    elsif ($new_tokens[1] =~ $self->{data}->__ago('week')) {
        $self->_subtract(day => (7 * $new_tokens[0]));
        $self->_set_modified(3);
    } 
    # months ago
    elsif ($new_tokens[1] =~ $self->{data}->__ago('month')) {
        $self->_subtract(month => $new_tokens[0]);
        $self->_set_modified(3);
    } 
    # years ago
    elsif ($new_tokens[1] =~ $self->{data}->__ago('year')) {
        $self->_subtract(year => $new_tokens[0]);
        $self->_set_modified(3);
    }
}

sub _now {
    my $self = shift;

    $self->_add_trace;

    my @new_tokens = splice(@{$self->{tokens}}, $self->{index}, 4);

    # days
    if ($new_tokens[1] =~ $self->{data}->__now('day')) {
        # days before now
        if ($new_tokens[2] =~ $self->{data}->__now('before')) {
            $self->_subtract(day => $new_tokens[0]);
            $self->_set_modified(4);
        } 
        # days from now
	elsif ($new_tokens[2] =~ $self->{data}->__now('from')) {
            $self->_add(day => $new_tokens[0]);
            $self->_set_modified(4);
        }
    } 
    # weeks
    elsif ($new_tokens[1] =~ $self->{data}->__now('week')) {
        # weeks before now
        if ($new_tokens[2] =~ $self->{data}->__now('before')) {
            $self->_subtract(day => (7 * $new_tokens[0]));
            $self->_set_modified(4);
        } 
        # weeks from now
	elsif ($new_tokens[2] =~ $self->{data}->__now('from')) {
            $self->_add(day => (7 * $new_tokens[0]));
            $self->_set_modified(4);
        }
     } 
     # months
     elsif ($new_tokens[1] =~ $self->{data}->__now('month')) {
         # months before now
         if ($new_tokens[2] =~ $self->{data}->__now('before')) {
             $self->_subtract(month => $new_tokens[0]);
             $self->_set_modified(4);
         } 
         # months from now
	 elsif ($new_tokens[2] =~ $self->{data}->__now('from')) {
             $self->_add(month => $new_tokens[0]);
             $self->_set_modified(4);
         }
     } 
     # years
     elsif ($new_tokens[1] =~ $self->{data}->__now('year')) {
         # years before now
         if ($new_tokens[2] =~ $self->{data}->__now('before')) {
             $self->_subtract(year => $new_tokens[0]);
             $self->_set_modified(4);
         } 
         # years from now
	 elsif ($new_tokens[2] =~ $self->{data}->__now('from')) {
             $self->_add(year => $new_tokens[0]);
             $self->_set_modified(4);
         }
     }
}

sub _daytime {
    my $self = shift;

    $self->_add_trace;

    my $hour_token;
    my @tokens = @{$self->{data}->__daytime('tokens')};

    $self->{hours_before} ||= 0;

    # unless german as language metdata
    unless ($self->{Lang} eq 'de') {
        # [0-9] in the
        if (all { ${$self->_token($_->[0])} =~ $tokens[$_->[1]] } @{[[-3,0],[-2,1],[-1,2]]}) {
            $hour_token = ${$self->_token(-3)};
            $self->_set_modified(3);
        }
    } 
    # [0-9] am
    elsif (all { ${$self->_token($_->[0])} =~ $tokens[$_->[1]] } @{[[-2,0],[-1,1]]}) {
        $hour_token = ${$self->_token(-2)};
        $self->_set_modified(2);
    }

    # morning
    if (${$self->_token(0)} =~ $self->{data}->__daytime('morning')) {
        my $hour = ($hour_token
          ? $hour_token
          : ($self->{Opts}{daytime}{morning}
             ? $self->{Opts}{daytime}{morning}
             : MORNING - $self->{hours_before}));

        if ($self->_valid_time(hour => $hour)) {
            $self->_set(hour => $hour);
            $self->{hours_before} = 0;
            $self->_set_modified(1);
        }
    } 
    # afternoon
    elsif (${$self->_token(0)} =~ $self->{data}->__daytime('afternoon')) {
        my $hour = ($hour_token
          ? $hour_token + 12 
          : ($self->{Opts}{daytime}{afternoon}
             ? $self->{Opts}{daytime}{afternoon}
             : AFTERNOON - $self->{hours_before}));

        if ($self->_valid_time(hour => $hour)) {
            $self->_set(hour => $hour);
            $self->{hours_before} = 0;
            $self->_set_modified(1);
        }
    } 
    # evening
    else {
       my $hour = ($hour_token
          ? $hour_token + 12
          : ($self->{Opts}{daytime}{evening}
             ? $self->{Opts}{daytime}{evening}
             : EVENING - $self->{hours_before}));

        if ($self->_valid_time(hour => $hour)) {
            $self->_set(hour => $hour);
            $self->{hours_before} = 0;
            $self->_set_modified(1);
        }
    }

    $self->_set(minute => 0);
}

sub _months {
    my $self = shift;

    $self->_add_trace;

    foreach my $key_month (keys %{$self->{data}->{months}}) {
        my $key_month_short = substr($key_month, 0, 3);

        foreach my $i qw(0 1) {
            # Month or month abbreviation encountered?
            if (any { ${$self->_token($i)} =~ $_ } @{[qr/$key_month/i, qr/$key_month_short/i]}) {
                # Set month & flag modification state
                if ($self->_valid_date(month => $self->{data}->{months}->{$key_month})) {
                    $self->_set(month => $self->{data}->{months}->{$key_month});
                    $self->_set_modified(1);
                }

                # Set day for: month [0-9] & remove day from tokens
                if (my ($day) = ${$self->_token(1)} =~ $self->{data}->__months('number')) {
                    if ($self->_valid_date(day => $day)) {
                        $self->_set(day => $day);
                        $self->_set_modified(1);
                    }

                    splice(@{$self->{tokens}}, $self->{index}+$i+1, 1);
                } 
                # Set day for: [0-9] month & remove day from tokens
		elsif (($day) = ${$self->_token($i-1)} =~ $self->{data}->__months('number')) {
                    if ($self->_valid_date(day => $day)) {
                        $self->_set(day => $day);
                        $self->_set_modified(1);
                    }

                    splice(@{$self->{tokens}}, $self->{index}+$i-1, 1);
                }
            }
        }
    }
}

sub _number {
    my ($self, $often) = @_;

    $self->_add_trace;

    # Return for: [0-9] in ...
    return if ${$self->_token(1)} eq 'in'
           or !defined $self->{data}->__number('month')
           or !defined $self->{data}->__number('hour')
           or !defined $self->{data}->__number('before')
           or !defined $self->{data}->__number('after');

    # [0-9] months ...
    if (${$self->_token(1)} =~ $self->{data}->__number('month')) {
        $self->_add(month => $often);

        if ($self->{datetime}->month() > 12) {
            $self->_subtract(month => 12);
        }

        $self->_set_modified(1);
    } 
    # hours
    elsif (${$self->_token(1)} =~ $self->{data}->__number('hour')) {
        $self->_set_modified(1);

        # [0-9] hours before ...
        if (${$self->_token(2)} =~ $self->{data}->__number('before')) {
            $self->{hours_before} = $often;
            $self->_set_modified(1);
        } 
        # [0-9] hours after ...
	elsif (${$self->_token(2)} =~ $self->{data}->__number('after')) {
            $self->{hours_after} = $often;
            $self->_set_modified(1);
        }
    } 
    # [0-9] day ...
    else {
        if ($self->_valid_date(day => $often)) {
            $self->_set(day => $often);
            $self->_set_modified(1);
        }
    }
}

sub _at {
    my ($self, $hour_token, $min_token, $timeframe, $noon_midnight) = @_;

    $self->_add_trace;

    foreach my $token (@{$self->{tokens}}) {
        $self->_set_modified(1) and last if $token eq 'at';
    }

    # Capture am/pm & set timeframe
    if (!$timeframe && ${$self->_token(1)} && ${$self->_token(1)} =~ /^[ap]m$/i) {
        $timeframe = ${$self->_token(1)};
    }

    # german um (engl. at)
    if ($self->{Lang} eq 'de') {
        foreach my $token (@{$self->{tokens}}) {
            $self->_set_modified(1) if $token =~ /um/i;
        }
    }

    # [0-9] ...
    if ($hour_token) {
        if ($self->_valid_time(hour => $hour_token)) {
            $self->_set(hour => $hour_token);
        }

        $min_token =~ s/:// if defined $min_token;

        if (!defined $min_token) {
            $self->_set(minute => 0);
            $self->_set_modified(1);
        } 
	elsif ($self->_valid_time(min => $min_token)) {
            $self->_set(minute => $min_token);
            $self->_set_modified(1);
        }

        # am/pm
        if ($timeframe) {
            $self->_set_modified(1);

            if ($timeframe =~ /^pm$/i) {
                $self->_add(hour => 12);
                unless ($min_token) {
                    $self->_set(minute => 0);
                }
            }
        }
    } 
    # Either noon or midnight
    elsif ($noon_midnight) {
        $self->{hours_before} ||= 0;

        # noon
        if ($noon_midnight =~ $self->{data}->__at('noon')) {
            $self->_set(hour => 12);
            $self->_set(minute => 0);

            # [0-9] hours before noon
            if ($self->{hours_before}) {
                $self->_subtract(hour => $self->{hours_before});
                $self->_set_modified(1);
            } 
            # [0-9] hours after noon
	    elsif ($self->{hours_after}) {
                $self->_add(hour => $self->{hours_after});
                $self->_set_modified(1);
            }

            $self->_set_modified(1);
            delete $self->{hours_before};
        } 
        # midnight
	elsif ($noon_midnight =~ $self->{data}->__at('midnight')) {
            $self->_set(hour => 0);
            $self->_set(minute => 0);

            # [0-9] hours before midnight ...
            if ($self->{hours_before}) {
                $self->_subtract(hour => $self->{hours_before});
            } 
            # [0-9] hours after midnight ...
	    elsif ($self->{hours_after}) {
                $self->_add(hour => $self->{hours_after});
            }

            $self->_set_modified(1);
            $self->_add(day => 1);
        }
    }
}

sub _weekday {
    my $self = shift;

    $self->_add_trace;

    foreach my $key_weekday (keys %{$self->{data}->{weekdays}}) {
        # Weekday abbreviation: monday -> mon
        my $weekday_short = lc substr($key_weekday, 0, 3);

        # Either full weekday or abbreviation found
        if (any { ${$self->_token(0)} =~ $_ } @{[qr/$key_weekday/i, qr/^$weekday_short$/i]}) {
            $key_weekday = ucfirst lc $key_weekday;

            my $days_diff;

            # Set current weekday by adding the day difference
            if ($self->{data}->{weekdays}->{$key_weekday} > $self->{datetime}->wday) {
                $days_diff = $self->{data}->{weekdays}->{$key_weekday} - $self->{datetime}->wday;
                $self->_add(day => $days_diff);
            } 
            # Set current weekday by subtracting the difference
	    else {
                $days_diff = $self->{datetime}->wday - $self->{data}->{weekdays}->{$key_weekday};
                $self->_subtract(day => $days_diff);
            }

            $self->_set_modified(1);
            last;
        }
    }
}

sub _this_in {
    my $self = shift;

    $self->_add_trace;

    $self->_set_modified(1);

    # in [0-9] hour(s)
    if (${$self->_token(1)} =~ $self->{data}->__this_in('hour')) {
        $self->_add(hour => ${$self->_token(0)});
        $self->_set_modified(2);

        return;
    }

    foreach my $key_weekday (keys %{$self->{data}->{weekdays}}) {
        # Weekday abbreviation: monday -> mon
        my $weekday_short = lc substr($key_weekday, 0, 3);

        # weekday or weekday abbreviation
        if (any { ${$self->_token(0)} =~ $_ } @{[qr/$key_weekday/i, qr/$weekday_short/i]}) {
            my $days_diff = $self->{data}->{weekdays}->{$key_weekday} - $self->{datetime}->wday;

            $self->_add(day => $days_diff);
            $self->{buffer} = '';
            $self->_set_modified(1);

            last;
        }

        # weekday this week
        if (${$self->_token(0)} =~ $self->{data}->__this_in('week')) {
            my $weekday = ucfirst lc ${$self->_token(-2)};
            my $days_diff = Decode_Day_of_Week($weekday) - $self->{datetime}->wday;

            $self->_add(day => $days_diff);
            $self->{buffer} = '';
            $self->_set_modified(1);

            last;
        }

        # months
        foreach my $month (keys %{$self->{data}->{months}}) {
             if (${$self->_token(0)} =~ /$month/i) {
                foreach my $weekday (keys %{$self->{data}->{weekdays}}) {
                    # [0-9] weekday this month
                    if (${$self->_token(-2)} =~ /$weekday/i) {

                        my ($often) = ${$self->_token(-3)} =~ $self->{data}->__this_in('number');
                        my ($year, $month, $day) =
                        Nth_Weekday_of_Month_Year($self->{datetime}->year, $self->{data}->{months}->{$month}, 
                          $self->{data}->{weekdays}->{$weekday}, $often);

                        if (check_date($year, $month, $day)) {
                            $self->_set(year => $year);
                            $self->_set(month => $month);
                            $self->_set(day => $day);
                            $self->_set_modified(2);
                        }

                        splice(@{$self->{tokens}}, $self->{index}-3, 4);
                    }
                }
            }
        }
    }
}

sub _next {
    my $self = shift;

    $self->_add_trace;

    foreach my $key_weekday (keys %{$self->{data}->{weekdays}}) {
        # Weekday abbreviation: monday -> mon
        my $weekday_short = lc substr($key_weekday, 0, 3);

        # weekday or weekday abbreviation
        if (${$self->_token(0)} =~ /$key_weekday/i || ${$self->_token(0)} eq $weekday_short) {
            my $days_diff = (7 - $self->{datetime}->wday) + Decode_Day_of_Week($key_weekday);

            $self->_add(day => $days_diff);
            $self->{buffer} = '';
            $self->_set_modified(1);

            last;
        }

        # weekday next week
        if (${$self->_token(0)} =~ $self->{data}->__next('week')) {
            my $weekday = ucfirst lc ${$self->_token(-2)};
            my $days_diff = (7 - $self->{datetime}->wday) + Decode_Day_of_Week($weekday);

            $self->_add(day => $days_diff);
            $self->{buffer} = '';
            $self->_set_modified(2);

            last;
        }

        # ... next month
        if (${$self->_token(0)} =~ $self->{data}->__next('month')) {
            $self->_add(month => 1);

            # [0-9] day next month
            if (${$self->_token(-2)} =~ $self->{data}->__next('day')) {
                my $day = ${$self->_token(-3)};
                $day =~ s/$self->{data}->__next('number')/$1/i;

                if ($self->_valid_date(day => $day)) {
                    $self->_set(day => $day);
                    $self->_set_modified(2);
                }
            }

            $self->_setmonthday;
            $self->{buffer} = '';
            $self->_set_modified(2);

            last;
        }

        # next [month]
        if (any { ${$self->_token(0)} =~ /$_/i } keys %{$self->{data}->{months}}) {
            my $month = $self->{data}->{months}->{ucfirst ${$self->_token(0)}};

            $self->_add(year => 1);
            $self->_set(month => $month);

            $self->_setyearday;
            $self->{buffer} = '';
            $self->_set_modified(2);

            last;
        }

        # ... next year
        if (${$self->_token(0)} =~ $self->{data}->__next('year')) {
            $self->_add(year => 1);

            # [0-9] month next year
            if (${$self->_token(-2)} =~ $self->{data}->__next('month')) {
                my $month = ${$self->_token(-3)};
                $month =~ s/$self->{data}->__next('number')/$1/i;

                if ($self->_valid_date(month => $month)) {
                    $self->_set(month => $month);
                    $self->_set_modified(2);
                }
            }

            $self->_setyearday;
            $self->{buffer} = '';
            $self->_set_modified(2);

            last;
        }
    }
}

sub _last {
    my $self = shift;

    $self->_add_trace;

    $self->_set_modified(1);

    foreach my $key_weekday (keys %{$self->{data}->{weekdays}}) {
        # Weekday abbreviation: monday -> mon
        my $weekday_short = lc substr($key_weekday, 0, 3);

        # weekday or weekday abbreviation
        if (${$self->_token(0)} =~ /$key_weekday/i || ${$self->_token(0)} eq $weekday_short) {
            my $days_diff = $self->{datetime}->wday + (7 - $self->{data}->{weekdays}->{$key_weekday});
            $self->_subtract(day => $days_diff);
            $self->{buffer} = '';
            $self->_set_modified(1);

            last;
        }
    }

    # ... week
    if (${$self->_token(0)} =~ $self->{data}->__last('week')) {
        $self->_set_modified(1);

        # last week weekday
        if (exists $self->{data}->{weekdays}->{ucfirst lc ${$self->_token(1)}}) {
            $self->_setweekday($self->{index}+1);
        } 
        # weekday last week
	elsif (exists $self->{data}->{weekdays}->{ucfirst lc ${$self->_token(-2)}}) {
            $self->_setweekday($self->{index}-2);
        } 
        # [0-9] day last week
	elsif (${$self->_token(-2)} =~ $self->{data}->__last('day')) {
            my $days_diff = (7 + $self->{datetime}->wday);

            $self->_subtract(day => $days_diff);

            my $day = ${$self->_token(-3)};
            $day =~ s/$self->{data}->__last('number')/$1/i;

            $self->_add(day => $day);
            $self->{buffer} = '';
            $self->_set_modified(2);
        }
    }

    # last [month]
    if (any { ${$self->_token(0)} =~ /$_/i } keys %{$self->{data}->{months}}) {
        my $month = $self->{data}->{months}->{ucfirst ${$self->_token(0)}};

        $self->_subtract(year => 1);
        $self->_set(month => $month);

        $self->_setyearday;
        $self->{buffer} = '';
        $self->_set_modified(2);
    }

    # ... month
    if (${$self->_token(0)} =~ $self->{data}->__last('month')) {
        $self->_subtract(month => 1);
        $self->_set_modified(1);

        # [0-9] day last month
        if (${$self->_token(-2)} =~ $self->{data}->__last('day')) {
            my $day = ${$self->_token(-3)};
            $day =~ s/$self->{data}->__last('number')/$1/i;

            if ($self->_valid_date(day => $day)) {
                $self->_set(day => $day);
                $self->_set_modified(2);
            }
        }

        $self->{buffer} = '';
        $self->_setmonthday;
    }

    # ... year
    if (${$self->_token(0)} =~ $self->{data}->__last('year')) {
        $self->_subtract(year => 1);

        $self->_setyearday;
        $self->_set_modified(1);

        $self->{buffer} = '';
     }
}

sub _monthdays_limit {
    my $self = shift;

    my $actual_monthdays = Days_in_Month($self->{datetime}->year, $self->{datetime}->month);

    # Days in month overlap days possible.
    if ($self->{datetime}->day > $actual_monthdays) {
        $self->{datetime}->add(months => 1);
        $self->_set(day => ($self->{datetime}->day - $actual_monthdays));

        $self->_set_modified(1);
    } 
    # Days in month below lower boundary.
    elsif ($self->{datetime}->day < 1) {
        $actual_monthdays = Days_in_Month($self->{datetime}->year, ($self->{datetime}->month-1));

        $self->_subtract(month => 1);
        $self->_set(day => ($actual_monthdays - $self->{datetime}->day));

        $self->_set_modified(1);
    }
}

sub _day {
    my $self = shift;

    $self->_add_trace;

    # Either today, yesterday or tomorrow
    if (${$self->_token(0)} =~ $self->{data}->__day('init')) {
        # yesterday
        if (${$self->_token(0)} =~ $self->{data}->__day('yesterday')) {
            $self->_subtract(day => 1);
        }

        # tomorrow
        if (${$self->_token(0)} =~ $self->{data}->__day('tomorrow')) {
            if ($self->{Lang} eq 'de') {
                # skip if we have a weekday followed by morning
                if (none { ${$self->_token(-1)} =~ $_ } keys %{$self->{data}->{weekdays}}) {
                    $self->_add(day => 1);
                }
            } 
	    else {
                $self->_add(day => 1);
            }
        }

        $self->_set_modified(1);

        # [0-9] hours before yesterday/tomorrow
        if ($self->{hours_before}) {
            my $hour = 24 - $self->{hours_before};
            if ($self->_valid_time(hour => $hour)) {
                $self->_set(hour => $hour);
            }

            if (${$self->_token(2)} !~ $self->{data}->__day('noonmidnight')) {
                $self->_subtract(day => 1);
            }
        } 
        # [0-9] hours after yesterday/tomorrow
	elsif ($self->{hours_after}) {
            my $hour = 0 + $self->{hours_after};
            if ($self->_valid_time(hour => $hour)) {
                $self->_set(hour => $hour);
            }
        }
    }

    # XXX: Make negative values positive; investigate further, possibly broken.
    if ($self->{datetime}->hour < 0) {
        my ($subtract) = $self->{datetime}->hour =~ /\-(.*)/;
        my $hour = 12 - $subtract;

        if ($self->_valid_time(hour => $hour)) {
            $self->_set(hour => $hour);
        }
    }
}

sub _setyearday {
    my $self = shift;

    # day
    if (${$self->_token(-2)} =~ $self->{data}->__setyearday('day')) {
        $self->_set(month => 1);

        # [0-9] day
        my $days = ${$self->_token(-3)};
        $days =~ s/$self->{data}->__setyearday('ext')/$1/i;

        # calculate year, month & day
        my ($year, $month, $day) = Add_Delta_Days($self->{datetime}->year, 1, 1, $days - 1);

        $self->_set(day => $day);
        $self->{datetime}->set_month($month);
        $self->{datetime}->set_year($year);
    }
}

sub _setmonthday {
    my $self = shift;

    foreach my $weekday (keys %{$self->{data}->{weekdays}}) {
        # monday, tuesday, ...
        if (${$self->_token(-2)} =~ /$weekday/i) {
            # [0-9] weekday ...
            my ($often) = ${$self->_token(-3)} =~ /^(\d{1,2})(?:st|nd|rd|th)?$/i;
            # calculate year, month & day
            my ($year, $month, $day) = Nth_Weekday_of_Month_Year($self->{datetime}->year, 
                                                                ($self->{datetime}->month),
                                                                 $self->{data}->{weekdays}->{$weekday},
                                                                 $often);

            $self->{datetime}->set_year($year);
            $self->_set(month => $month);
            $self->_set(day => $day);
        }
    }
}

sub _setweekday {
    my ($self, $index) = @_;

    # Fetch weekday & calculate amount of days
    my $weekday = ucfirst(lc($self->{tokens}->[$index]));
    my $days_diff = $self->{datetime}->wday + (7 - $self->{data}->{weekdays}->{$weekday});

    $self->_subtract(day => $days_diff);
    $self->{buffer} = '';

    $self->_set_modified(1);
}

sub _add {
    my ($self, $unit, $value) = @_;

    $self->{modified}{$unit}++;

    $unit .= 's' unless $unit =~ /s$/;
    $self->{datetime}->add($unit => $value);
}

sub _subtract {
    my ($self, $unit, $value) = @_;

    $self->{modified}{$unit}++;

    $unit .= 's' unless $unit =~ /s$/;
    $self->{datetime}->subtract($unit => $value);
}

sub _set {
    my ($self, $unit, $value) = @_;

    $self->{modified}{$unit}++;

    my $setter = 'set_' . $unit;
    $self->{datetime}->$setter($value);
}

sub _valid_date {
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

sub _valid_time {
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

L<DateTime::Format::Natural>, L<DateTime>, L<Date::Calc>, L<http://datetime.perl.org>

=head1 AUTHOR

Steven Schubiger <schubiger@cpan.org>

=head1 LICENSE

This program is free software; you may redistribute it and/or
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
