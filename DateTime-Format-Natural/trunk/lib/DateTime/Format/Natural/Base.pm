package DateTime::Format::Natural::Base;

use strict;
use warnings;

use constant MORNING   => '08';
use constant AFTERNOON => '14';
use constant EVENING   => '20';

use DateTime;
use Date::Calc qw(Add_Delta_Days Days_in_Month
                  Decode_Day_of_Week
                  Nth_Weekday_of_Month_Year);

our $VERSION = '0.9';

$SIG{__WARN__} = \&_filter_warnings;

sub _ago {
    my $self = shift;

    my @new_tokens = splice(@{$self->{tokens}}, $self->{index}, 3);

    # seconds ago
    if ($new_tokens[1] =~ $self->{data}->__ago('second')) {
        $self->{datetime}->subtract(seconds => $new_tokens[0]);
        $self->_set_modified(3);
    # minutes ago
    } elsif ($new_tokens[1] =~ $self->{data}->__ago('minute')) {
        $self->{datetime}->subtract(minutes => $new_tokens[0]);
        $self->_set_modified(3);
    # hours ago
    } elsif ($new_tokens[1] =~ $self->{data}->__ago('hour')) {
        $self->{datetime}->subtract(hours => $new_tokens[0]);
        $self->_set_modified(3);
    # days ago
    } elsif ($new_tokens[1] =~ $self->{data}->__ago('day')) {
        $self->{datetime}->subtract(days => $new_tokens[0]);
        $self->_set_modified(3);
    # weeks ago
    } elsif ($new_tokens[1] =~ $self->{data}->__ago('week')) {
        $self->{datetime}->subtract(days => (7 * $new_tokens[0]));
        $self->_set_modified(3);
    # months ago
    } elsif ($new_tokens[1] =~ $self->{data}->__ago('month')) {
        $self->{datetime}->subtract(months => $new_tokens[0]);
        $self->_set_modified(3);
    # years ago
    } elsif ($new_tokens[1] =~ $self->{data}->__ago('year')) {
        $self->{datetime}->subtract(years => $new_tokens[0]);
        $self->_set_modified(3);
    }
}

sub _now {
    my $self = shift;

    my @new_tokens = splice(@{$self->{tokens}}, $self->{index}, 4);

    # days
    if ($new_tokens[1] =~ $self->{data}->__now('day')) {
        # days before now
        if ($new_tokens[2] =~ $self->{data}->__now('before')) {
            $self->{datetime}->subtract(days => $new_tokens[0]);
            $self->_set_modified(4);
        # days from now
        } elsif ($new_tokens[2] =~ $self->{data}->__now('from')) {
            $self->{datetime}->add(days => $new_tokens[0]);
            $self->_set_modified(4);
        }
    # weeks
    } elsif ($new_tokens[1] =~ $self->{data}->__now('week')) {
        # weeks before now
        if ($new_tokens[2] =~ $self->{data}->__now('before')) {
            $self->{datetime}->subtract(days => (7 * $new_tokens[0]));
            $self->_set_modified(4);
        # weeks from now
        } elsif ($new_tokens[2] =~ $self->{data}->__now('from')) {
            $self->{datetime}->add(days => (7 * $new_tokens[0]));
            $self->_set_modified(4);
        }
     # months
     } elsif ($new_tokens[1] =~ $self->{data}->__now('month')) {
         # months before now
         if ($new_tokens[2] =~ $self->{data}->__now('before')) {
             $self->{datetime}->subtract(months => $new_tokens[0]);
             $self->_set_modified(4);
         # months from now
         } elsif ($new_tokens[2] =~ $self->{data}->__now('from')) {
             $self->{datetime}->add(months => $new_tokens[0]);
             $self->_set_modified(4);
         }
     # years
     } elsif ($new_tokens[1] =~ $self->{data}->__now('year')) {
         # years before now
         if ($new_tokens[2] =~ $self->{data}->__now('before')) {
             $self->{datetime}->subtract(years => $new_tokens[0]);
             $self->_set_modified(4);
         # years from now
         } elsif ($new_tokens[2] =~ $self->{data}->__now('from')) {
             $self->{datetime}->add(years => $new_tokens[0]);
             $self->_set_modified(4);
         }
     }
}

sub _daytime {
    my $self = shift;

    my $hour_token;
    my @tokens = @{$self->{data}->__daytime('tokens')};

    # unless german as language metdata
    unless ($self->{lang} eq 'de') {
        # [0-9] in the
        if ($self->{tokens}->[$self->{index}-3] =~ $tokens[0]
        and $self->{tokens}->[$self->{index}-2] =~ $tokens[1]
        and $self->{tokens}->[$self->{index}-1] =~ $tokens[2]) {
            $hour_token = $self->{tokens}->[$self->{index}-3];
            $self->_set_modified(3);
        }
    # [0-9] am
    } elsif ($self->{tokens}->[$self->{index}-2] =~ $tokens[0]
         and $self->{tokens}->[$self->{index}-1] =~ $tokens[1]) {
             $hour_token = $self->{tokens}->[$self->{index}-2];
             $self->_set_modified(2);
    }

    # morning
    if ($self->{tokens}->[$self->{index}] =~ $self->{data}->__daytime('morning')) {
        $self->{datetime}->set_hour($hour_token
          ? $hour_token
          : ($self->{opts}{daytime}{morning}
             ? $self->{opts}{daytime}{morning}
             : MORNING - $self->{hours_before}));

        undef $self->{hours_before};
        $self->_set_modified(1);
    # afternoon
    } elsif ($self->{tokens}->[$self->{index}] =~ $self->{data}->__daytime('afternoon')) {
        $self->{datetime}->set_hour($hour_token
          ? $hour_token + 12 
          : ($self->{opts}{daytime}{afternoon}
             ? $self->{opts}{daytime}{afternoon}
             : AFTERNOON - $self->{hours_before}));

        undef $self->{hours_before};
        $self->_set_modified(1);
    # evening
    } else {
        $self->{datetime}->set_hour($hour_token
          ? $hour_token + 12
          : ($self->{opts}{daytime}{evening}
             ? $self->{opts}{daytime}{evening}
             : EVENING - $self->{hours_before}));

        undef $self->{hours_before};
        $self->_set_modified(1);
    }

    $self->{datetime}->set_minute(00);
}

sub _months {
    my $self = shift;

    foreach my $key_month (keys %{$self->{data}->{months}}) {
        my $key_month_short = substr($key_month, 0, 3);

        foreach my $i qw(0 1) {
            # Month or month abbreviation encountered?
            if ($self->{tokens}->[$self->{index}+$i] =~ /$key_month/i
             || $self->{tokens}->[$self->{index}+$i] =~ /$key_month_short/i) {
                # Set month & flag modification state
                $self->{datetime}->set_month($self->{data}->{months}->{$key_month});
                $self->_set_modified(1);

                # Set day for: month [0-9] & remove day from tokens
                if ($self->{tokens}->[$self->{index}+$i+1] =~ $self->{data}->__months('number')) {
                    $self->{datetime}->set_day($1);
                    $self->_set_modified(1);

                    splice(@{$self->{tokens}}, $self->{index}+$i+1, 1);
                # Set day for: [0-9] month & remove day from tokens
                } elsif ($self->{tokens}->[$self->{index}+$i-1] =~ $self->{data}->__months('number')) {
                    $self->{datetime}->set_day($1);
                    $self->_set_modified(1);

                    splice(@{$self->{tokens}}, $self->{index}+$i-1, 1);
                }
            }
        }
    }
}

sub _number {
    my ($self, $often) = @_;

    # Return for: [0-9] in ...
    return if $self->{tokens}->[$self->{index}+1] eq 'in';

    # [0-9] months ...
    if ($self->{tokens}->[$self->{index}+1] =~ $self->{data}->__number('month')) {
        $self->{datetime}->add(months => $often);

        if ($self->{datetime}->month() > 12) {
            $self->{datetime}->subtract(months => 12);
        }

        $self->_set_modified(1);
    # hours
    } elsif ($self->{tokens}->[$self->{index}+1] =~ $self->{data}->__number('hour')) {
        $self->_set_modified(1);

        # [0-9] hours before ...
        if ($self->{tokens}->[$self->{index}+2] =~ $self->{data}->__number('before')) {
            $self->{hours_before} = $often;
            $self->_set_modified(1);
        # [0-9] hours after ...
        } elsif ($self->{tokens}->[$self->{index}+2] =~ $self->{data}->__number('after')) {
            $self->{hours_after} = $often;
            $self->_set_modified(1);
        }
    # [0-9] day ...
    } else {
        $self->{datetime}->set_day($often);
        $self->_set_modified(1);
    }
}

sub _at {
    my ($self, $hour_token, $min_token, $timeframe, $noon_midnight) = @_;

    foreach my $token (@{$self->{tokens}}) {
        $self->_set_modified(1) and last if $token eq 'at';
    }

    # Capture am/pm & set timeframe
    if (!$timeframe && $self->{tokens}->[$self->{index}+1] 
        && $self->{tokens}[$self->{index}+1] =~ /^[ap]m$/i) {
        $timeframe = $self->{tokens}[$self->{index}+1];
    }

    # german um (engl. at)
    if ($self->{lang} eq 'de') {
        foreach my $token (@{$self->{tokens}}) {
            $self->_set_modified(1) if $token =~ /um/i;
        }
    }

    # [0-9] ...
    if ($hour_token) {
        $self->{datetime}->set_hour($hour_token);
        $min_token =~ s!:!! if defined($min_token);
        $self->{datetime}->set_minute($min_token || 00);

        $self->_set_modified(1);

        # am/pm
        if ($timeframe) {
            $self->_set_modified(1);

            if ($timeframe =~ /^pm$/i) {
                $self->{datetime}->add(hours => 12);
                unless ($min_token) {
                    $self->{datetime}->set_minute(0);
                }
            }
        }
    # Either noon or midnight
    } elsif ($noon_midnight) {
        $self->{hours_before} ||= 0;

        # noon
        if ($noon_midnight =~ $self->{data}->__at('noon')) {
            $self->{datetime}->set_hour(12);
            $self->{datetime}->set_minute(0);

            # [0-9] hours before noon
            if ($self->{hours_before}) {
                $self->{datetime}->subtract(hours => $self->{hours_before});
                $self->_set_modified(1);
            # [0-9] hours after noon
            } elsif ($self->{hours_after}) {
                $self->{datetime}->add(hours => $self->{hours_after});
                $self->_set_modified(1);
            }

            $self->_set_modified(1);
            undef $self->{hours_before};
        # midnight
        } elsif ($noon_midnight =~ $self->{data}->__at('midnight')) {
            $self->{datetime}->set_hour(0);
            $self->{datetime}->set_minute(0);

            # [0-9] hours before midnight ...
            if ($self->{hours_before}) {
                $self->{datetime}->subtract(hours => $self->{hours_before});
            # [0-9] hours after midnight ...
            } elsif ($self->{hours_after}) {
                $self->{datetime}->add(hours => $self->{hours_after});
            }

            $self->_set_modified(1);
            $self->{datetime}->add(days => 1);
        }
    }
}

sub _weekday {
    my $self = shift;

    foreach my $key_weekday (keys %{$self->{data}->{weekdays}}) {
        # Weekday abbreviation: monday -> mon
        my $weekday_short = lc(substr($key_weekday,0,3));

        # Either full weekday or abbreviation found
        if ($self->{tokens}->[$self->{index}] =~ /$key_weekday/i
         || $self->{tokens}->[$self->{index}] =~ /^$weekday_short$/i) {
            $key_weekday = ucfirst(lc($key_weekday));

            my $days_diff;

            # Set current weekday by adding the day difference
            if ($self->{data}->{weekdays}->{$key_weekday} > $self->{datetime}->wday) {
                $days_diff = $self->{data}->{weekdays}->{$key_weekday} - $self->{datetime}->wday;
                $self->{datetime}->add(days => $days_diff);
            # Set current weekday by subtracting the difference
            } else {
                $days_diff = $self->{datetime}->wday - $self->{data}->{weekdays}->{$key_weekday};
                $self->{datetime}->subtract(days => $days_diff);
            }

            $self->_set_modified(1);
            last;
        }
    }
}

sub _this_in {
    my $self = shift;

    $self->_set_modified(1);

    # in [0-9] hour(s)
    if ($self->{tokens}->[$self->{index}+1] =~ $self->{data}->__this_in('hour')) {
        $self->{datetime}->add(hours => $self->{tokens}->[$self->{index}]);
        $self->_set_modified(2);

        return;
    }

    foreach my $key_weekday (keys %{$self->{data}->{weekdays}}) {
        # Weekday abbreviation: monday -> mon
        my $weekday_short = lc(substr($key_weekday,0,3));

        # weekday or weekday abbreviation
        if ($self->{tokens}->[$self->{index}] =~ /$key_weekday/i
         || $self->{tokens}->[$self->{index}] eq $weekday_short) {
            my $days_diff = $self->{data}->{weekdays}->{$key_weekday} - $self->{datetime}->wday;

            $self->{datetime}->add(days => $days_diff);
            $self->{buffer} = '';
            $self->_set_modified(1);

            last;
        }

        # weekday this week
        if ($self->{tokens}->[$self->{index}] =~ $self->{data}->__this_in('week')) {
            my $weekday = ucfirst(lc($self->{tokens}->[$self->{index}-2]));
            my $days_diff = Decode_Day_of_Week($weekday) - $self->{datetime}->wday;

            $self->{datetime}->add(days => $days_diff);
            $self->{buffer} = '';
            $self->_set_modified(1);

            last;
        }

        # months
        foreach my $month (keys %{$self->{data}->{months}}) {
             if ($self->{tokens}->[$self->{index}] =~ /$month/i) {
                foreach my $weekday (keys %{$self->{data}->{weekdays}}) {
                    # [0-9] weekday this month
                    if ($self->{tokens}->[$self->{index}-2] =~ /$weekday/i) {

                        my ($often) = $self->{tokens}->[$self->{index}-3] =~ $self->{data}->__this_in('number');
                        my ($year, $month, $day) =
                        Nth_Weekday_of_Month_Year($self->{datetime}->year, $self->{data}->{months}->{$month}, 
                        $self->{data}->{weekdays}->{$weekday}, $often);
                        $self->{datetime}->set_year($year);
                        $self->{datetime}->set_month($month);
                        $self->{datetime}->set_day($day);

                        $self->_set_modified(2);

                        splice(@{$self->{tokens}}, $self->{index}-3, 4);
                    }
                }
            }
        }
    }
}

sub _next {
    my $self = shift;

    foreach my $key_weekday (keys %{$self->{data}->{weekdays}}) {
        # Weekday abbreviation: monday -> mon
        my $weekday_short = lc(substr($key_weekday,0,3));

        # weekday or weekday abbreviation
        if ($self->{tokens}->[$self->{index}] =~ /$key_weekday/i 
         || $self->{tokens}->[$self->{index}] eq $weekday_short) {
            my $days_diff = (7 - $self->{datetime}->wday) + Decode_Day_of_Week($key_weekday);

            $self->{datetime}->add(days => $days_diff);
            $self->{buffer} = '';
            $self->_set_modified(1);

            last;
        }

        # weekday next week
        if ($self->{tokens}->[$self->{index}] =~ $self->{data}->__next('week')) {
            my $weekday = ucfirst(lc($self->{tokens}->[$self->{index}-2]));
            my $days_diff = (7 - $self->{datetime}->wday) + Decode_Day_of_Week($weekday);

            $self->{datetime}->add(days => $days_diff);
            $self->{buffer} = '';
            $self->_set_modified(2);

            last;
        }

        # ... next month
        if ($self->{tokens}->[$self->{index}] =~ $self->{data}->__next('month')) {
            $self->{datetime}->add(months => 1);

            # [0-9] day next month
            if ($self->{tokens}->[$self->{index}-2] =~ $self->{data}->__next('day')) {
                my $day = $self->{tokens}->[$self->{index}-3];
                $day =~ s/$self->{data}->__next('number')/$1/ei;

                $self->{datetime}->set_day($day);
                $self->_set_modified(2);
            }

            $self->_setmonthday;
            $self->{buffer} = '';
            $self->_set_modified(2);

            last;
        }

        # ... next year
        if ($self->{tokens}->[$self->{index}] =~ $self->{data}->__next('year')) {
            $self->{datetime}->add(years => 1);

            # [0-9] month next year
            if ($self->{tokens}->[$self->{index}-2] =~ $self->{data}->__next('month')) {
                my $month = $self->{tokens}->[$self->{index}-3];
                $month =~ s/$self->{data}->__next('number')/$1/ei;

                $self->{datetime}->set_month($month);
                $self->_set_modified(2);
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

    $self->_set_modified(1);

    foreach my $key_weekday (keys %{$self->{data}->{weekdays}}) {
        # Weekday abbreviation: monday -> mon
        my $weekday_short = lc(substr($key_weekday,0,3));

        # weekday or weekday abbreviation
        if ($self->{tokens}->[$self->{index}] =~ /$key_weekday/i 
            || $self->{tokens}->[$self->{index}] eq $weekday_short) {
            my $days_diff = $self->{datetime}->wday + (7 - $self->{data}->{weekdays}->{$key_weekday});
            $self->{datetime}->subtract(days => $days_diff);
            $self->{buffer} = '';
            $self->_set_modified(1);

            last;
        }
    }

    # ... week
    if ($self->{tokens}->[$self->{index}] =~ $self->{data}->__last('week')) {
        $self->_set_modified(1);

        # last week weekday
        if (exists $self->{data}->{weekdays}->{ucfirst(lc($self->{tokens}->[$self->{index}+1]))}) {
            $self->_setweekday($self->{index}+1);
        # weekday last week
        } elsif (exists $self->{data}->{weekdays}->{ucfirst(lc($self->{tokens}->[$self->{index}-2]))}) {
            $self->_setweekday($self->{index}-2);
        # [0-9] day last week
        } elsif ($self->{tokens}->[$self->{index}-2] =~ $self->{data}->__last('day')) {
            my $days_diff = (7 + $self->{datetime}->wday);

            $self->{datetime}->subtract(days => $days_diff);

            my $day = $self->{tokens}->[$self->{index}-3];
            $day =~ s/$self->{data}->__last('number')/$1/ei;

            $self->{datetime}->add(days => $day);
            $self->{buffer} = '';
            $self->_set_modified(2);
        }
    }

    # ... month
    if ($self->{tokens}->[$self->{index}] =~ $self->{data}->__last('month')) {
        $self->{datetime}->subtract(months => 1);
        $self->_set_modified(1);

        # [0-9] day last month
        if ($self->{tokens}->[$self->{index}-2] =~ $self->{data}->__last('day')) {
            my $day = $self->{tokens}->[$self->{index}-3];
            $day =~ s/$self->{data}->__last('number')/$1/ei;

            $self->{datetime}->set_day($day);
        }

        $self->{buffer} = '';
        $self->_setmonthday;
    }

    # ... year
    if ($self->{tokens}->[$self->{index}] =~ $self->{data}->__last('year')) {
        $self->{datetime}->subtract(years => 1);

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
        $self->{datetime}->set_day($self->{datetime}->day - $actual_monthdays);

        $self->_set_modified(1);
    # Days in month below lower boundary.
    } elsif ($self->{datetime}->day < 1) {
        $actual_monthdays = Days_in_Month($self->{datetime}->year, ($self->{datetime}->month-1));

        $self->{datetime}->subtract(months => 1);
        $self->{datetime}->set_day($actual_monthdays - $self->{datetime}->day);

        $self->_set_modified(1);
    }
}

sub _day {
    my $self = shift;

    # Either today, yesterday or tomorrow
    if ($self->{tokens}->[$self->{index}] =~ $self->{data}->__day('init')) {
        # yesterday
        if ($self->{tokens}->[$self->{index}] =~ $self->{data}->__day('yesterday')) {
            $self->{datetime}->subtract(days => 1);
        }

        my ($skip1, $skip2);

        # tomorrow
        if ($self->{tokens}->[$self->{index}] =~ $self->{data}->__day('tomorrow')) {
            if ($self->{lang} eq 'de') {
                # skip if we don't mean tomorrow, but morning (german ambiguities)
                if ($self->{tokens}->[$self->{index}-1] =~ $self->{data}->__day('morning_prefix')
                 || $self->{tokens}->[$self->{index}-1] =~ $self->{data}->__day('at')
                 || $self->{tokens}->[$self->{index}-1] =~ $self->{data}->__day('when')) {
                    $skip1 = 1;
                }

                # skip if we have a weekday followed by morning
                for my $weekday (keys %{$self->{data}->{weekdays}}) {
                    if ($self->{tokens}->[$self->{index}-1] =~ /$weekday/i) {
                        $skip2 = 1;
                    }
                }

                $self->{datetime}->add(days => 1) unless ($skip1 || $skip2);
            } else {
                $self->{datetime}->add(days => 1);
            }
        }

        $self->_set_modified(1);

        # [0-9] hours before yesterday/tomorrow
        if ($self->{hours_before}) {
            $self->{datetime}->set_hour(24 - $self->{hours_before});

            if ($self->{tokens}->[$self->{index}+2] !~ $self->{data}->__day('noonmidnight')) {
                $self->{datetime}->subtract(days => 1);
            }
        # [0-9] hours after yesterday/tomorrow
        } elsif ($self->{hours_after}) {
            $self->{datetime}->set_hour(0 + $self->{hours_after});
        }
    }

    # XXX: Make negative values positive; investigate further, possibly broken.
    if ($self->{datetime}->hour < 0) {
        my ($subtract) = $self->{datetime}->hour =~ /\-(.*)/;
        $self->{datetime}->set_hour(12 - $subtract);
    }
}

sub _setyearday {
    my $self = shift;

    # day
    if ($self->{tokens}->[$self->{index}-2] =~ $self->{data}->__setyearday('day')) {
        $self->{datetime}->set_month(1);

        # [0-9] day
        my $days = $self->{tokens}->[$self->{index}-3];
        $days =~ s/$self->{data}->__setyearday('ext')/$1/ei;

        # calculate year, month & day
        my ($year, $month, $day) = Add_Delta_Days($self->{datetime}->year, 1, 1, $days - 1);

        $self->{datetime}->set_day($day);
        $self->{datetime}->set_month($month);
        $self->{datetime}->set_year($year);
    }
}

sub _setmonthday {
    my $self = shift;

    foreach my $weekday (keys %{$self->{data}->{weekdays}}) {
        # monday, tuesday, ...
        if ($self->{tokens}->[$self->{index}-2] =~ /$weekday/i) {
            # [0-9] weekday ...
            my ($often) = $self->{tokens}->[$self->{index}-3] =~ /^(\d{1,2})(?:st|nd|rd|th)?$/i;
            # calculate year, month & day
            my ($year, $month, $day) = Nth_Weekday_of_Month_Year($self->{datetime}->year, 
                                                                ($self->{datetime}->month),
                                                                 $self->{data}->{weekdays}->{$weekday},
                                                                 $often);

            $self->{datetime}->set_year($year);
            $self->{datetime}->set_month($month);
            $self->{datetime}->set_day($day);
        }
    }
}

sub _setweekday {
    my ($self, $index) = @_;

    # Fetch weekday & calculate amount of days
    my $weekday = ucfirst(lc($self->{tokens}->[$index]));
    my $days_diff = $self->{datetime}->wday + (7 - $self->{data}->{weekdays}->{$weekday});

    $self->{datetime}->subtract(days => $days_diff);
    $self->{buffer} = '';

    $self->_set_modified(1);
}

sub _filter_warnings {
    if ($_[0] =~ /uninitialized/ &&
        $_[0] =~ /pattern|string|subtraction/) {
        return;
    } else { print $_[0] }
};

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
