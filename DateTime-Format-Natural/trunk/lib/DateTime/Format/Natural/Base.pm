package DateTime::Format::Natural::Base;

use strict;
use warnings;

use DateTime;
use Date::Calc qw(Add_Delta_Days Days_in_Month
                  Decode_Day_of_Week
                  Nth_Weekday_of_Month_Year);

our $VERSION = '0.6';

$SIG{__WARN__} = \&_filter_warnings;

sub _ago {
    my $self = shift;

    my @new_tokens = splice(@{$self->{tokens}}, $self->{index}, 3);

    if ($new_tokens[1] =~ $self->{data}->__ago('hour')) {
        $self->{datetime}->subtract(hours => $new_tokens[0]);
        $self->_set_modified;
    } elsif ($new_tokens[1] =~ $self->{data}->__ago('day')) {
        $self->{datetime}->subtract(days => $new_tokens[0]);
        $self->_set_modified;
    } elsif ($new_tokens[1] =~ $self->{data}->__ago('week')) {
        $self->{datetime}->subtract(days => (7 * $new_tokens[0]));
        $self->_set_modified;
    } elsif ($new_tokens[1] =~ $self->{data}->__ago('month')) {
        $self->{datetime}->subtract(months => $new_tokens[0]);
        $self->_set_modified;
    } elsif ($new_tokens[1] =~ $self->{data}->__ago('year')) {
        $self->{datetime}->subtract(years => $new_tokens[0]);
        $self->_set_modified;
    }
}

sub _now {
    my $self = shift;

    my @new_tokens = splice(@{$self->{tokens}}, $self->{index}, 4);

    if ($new_tokens[1] =~ $self->{data}->__now('day')) {
        if ($new_tokens[2] =~ $self->{data}->__now('before')) {
            $self->{datetime}->subtract(days => $new_tokens[0]);
            $self->_set_modified;
        } elsif ($new_tokens[2] =~ $self->{data}->__now('from')) {
            $self->{datetime}->add(days => $new_tokens[0]);
            $self->_set_modified;
        }
    } elsif ($new_tokens[1] =~ $self->{data}->__now('week')) {
        if ($new_tokens[2] =~ $self->{data}->__now('before')) {
            $self->{datetime}->subtract(days => (7 * $new_tokens[0]));
            $self->_set_modified;
        } elsif ($new_tokens[2] =~ $self->{data}->__now('from')) {
            $self->{datetime}->add(days => (7 * $new_tokens[0]));
            $self->_set_modified;
        }
     } elsif ($new_tokens[1] =~ $self->{data}->__now('month')) {
         if ($new_tokens[2] =~ $self->{data}->__now('before')) {
             $self->{datetime}->subtract(months => $new_tokens[0]);
             $self->_set_modified;
         } elsif ($new_tokens[2] =~ $self->{data}->__now('from')) {
             $self->{datetime}->add(months => $new_tokens[0]);
             $self->_set_modified;
         }
     } elsif ($new_tokens[1] =~ $self->{data}->__now('year')) {
         if ($new_tokens[2] =~ $self->{data}->__now('before')) {
             $self->{datetime}->subtract(years => $new_tokens[0]);
             $self->_set_modified;
         } elsif ($new_tokens[2] =~ $self->{data}->__now('from')) {
             $self->{datetime}->add(years => $new_tokens[0]);
             $self->_set_modified;
         }
     }
}

sub _daytime {
    my $self = shift;

    my $hour_token;
    my @tokens = @{$self->{data}->__daytime('tokens')};

    unless ($self->{lang} eq 'de') {
        if ($self->{tokens}->[$self->{index}-3]     =~ $tokens[0]
            and $self->{tokens}->[$self->{index}-2] =~ $tokens[1]
            and $self->{tokens}->[$self->{index}-1] =~ $tokens[2]) {
                $hour_token = $self->{tokens}->[$self->{index}-3];
        }
    } elsif ($self->{tokens}->[$self->{index}-2]     =~ $tokens[0] 
             and $self->{tokens}->[$self->{index}-1] =~ $tokens[1]) {
                 $hour_token = $self->{tokens}->[$self->{index}-2];
    }
    if ($self->{tokens}->[$self->{index}] =~ $self->{data}->__daytime('morning')) {
        $self->{datetime}->set_hour($hour_token ? $hour_token : '08' - $self->{hours_before});
        undef $self->{hours_before};
        $self->_set_modified;
    } elsif ($self->{tokens}->[$self->{index}] =~ $self->{data}->__daytime('afternoon')) {
        $self->{datetime}->set_hour($hour_token ? $hour_token + 12 : '14' - $self->{hours_before});
        undef $self->{hours_before};
        $self->_set_modified;
    } else {
        $self->{datetime}->set_hour( $hour_token ? $hour_token + 12 : '14' - $self->{hours_before});
        undef $self->{hours_before};
        $self->_set_modified;
    }

    $self->{datetime}->set_minute(00);
}

sub _months {
    my $self = shift;

    foreach my $key_month (keys %{$self->{data}->{months}}) {
        my $key_month_short = substr($key_month, 0, 3);
        foreach my $i qw(0 1) {
            if ($self->{tokens}->[$self->{index}+$i] =~ /$key_month/i
                || $self->{tokens}->[$self->{index}+$i] =~ /$key_month_short/i) {
                   $self->{datetime}->set_month($self->{data}->{months}->{$key_month});
                   $self->_set_modified;
                   if ($self->{tokens}->[$self->{index}+$i+1] =~ $self->{data}->__months('number')) {
                       $self->{datetime}->set_day($1);
                       splice(@{$self->{tokens}}, $self->{index}+$i+1, 1);
                   } elsif ($self->{tokens}->[$self->{index}+$i-1] =~ $self->{data}->__months('number')) {
                      $self->{datetime}->set_day($1);
                      splice(@{$self->{tokens}}, $self->{index}+$i-1, 1);

                   }
             }
        }
    }
}

sub _number {
    my ($self, $often) = @_;

    return if $self->{tokens}->[$self->{index}+1] eq 'in';

    if ($self->{tokens}->[$self->{index}+1] =~ $self->{data}->__number('month')) {
        $self->{datetime}->add(months => $often);
        if ($self->{datetime}->month() > 12) {
            $self->{datetime}->subtract(months => 12);
        }
        $self->_set_modified;
    } elsif ($self->{tokens}->[$self->{index}+1] =~ $self->{data}->__number('hour')) {
        if ($self->{tokens}->[$self->{index}+2] =~ $self->{data}->__number('before')) {
            $self->{hours_before} = $often;
            $self->_set_modified;
        } elsif ($self->{tokens}->[$self->{index}+2] =~ $self->{data}->__number('after')) {
            $self->{hours_after} = $often;
            $self->_set_modified;
        }
    } else {
        $self->{datetime}->set_day($often);
        $self->_set_modified;
    }
}

sub _at {
    my ($self, $hour_token, $min_token, $timeframe, $noon_midnight)  = @_;

    if (!$timeframe && $self->{tokens}->[$self->{index}+1] 
        && $self->{tokens}[$self->{index}+1] =~ /^[ap]m$/i) {
        $timeframe = $self->{tokens}[$self->{index}+1];
    }

    if ($hour_token) {
        $self->{datetime}->set_hour($hour_token);
        $min_token =~ s!:!! if defined($min_token);
        $self->{datetime}->set_minute($min_token || 00);

        $self->_set_modified;

        if ($timeframe) {
            if ($timeframe =~ /^pm$/i) {
                $self->{datetime}->add(hours => 12);
                unless ($min_token) {
                    $self->{datetime}->set_minute(0);
                }
            }
        }
    } elsif ($noon_midnight) {
        $self->_set_modified;
        $self->{hours_before} ||= 0;
        if ($noon_midnight =~ $self->{data}->__at('noon')) {
            $self->{datetime}->set_hour(12);
            $self->{datetime}->set_minute(0);
            if ($self->{hours_before}) {
                $self->{datetime}->subtract(hours => $self->{hours_before});
            } elsif ($self->{hours_after}) {
                $self->{datetime}->add(hours => $self->{hours_after});
            }
            undef $self->{hours_before};
        } elsif ($noon_midnight =~ $self->{data}->__at('midnight')) {
            $self->{datetime}->set_hour(0);
            $self->{datetime}->set_minute(0);
            if ($self->{hours_before}) {
                $self->{datetime}->subtract(hours => $self->{hours_before});
            } elsif ($self->{hours_after}) {
                $self->{datetime}->add(hours => $self->{hours_after});
            }
            $self->{datetime}->add(days => 1);
        }
    }
}

sub _weekday {
    my $self = shift;

    foreach my $key_weekday (keys %{$self->{data}->{weekdays}}) {
        my $weekday_short = lc(substr($key_weekday,0,3));
        if ($self->{tokens}->[$self->{index}] =~ /$key_weekday/i
            || $self->{tokens}->[$self->{index}] =~ /^$weekday_short$/i) {
            $key_weekday = ucfirst(lc($key_weekday));
            my $days_diff;
            if ($self->{data}->{weekdays}->{$key_weekday} > $self->{datetime}->wday) {
                $days_diff = $self->{data}->{weekdays}->{$key_weekday} - $self->{datetime}->wday;
                $self->{datetime}->add(days => $days_diff);
            } else {
                $days_diff = $self->{datetime}->wday - $self->{data}->{weekdays}->{$key_weekday};
                $self->{datetime}->subtract(days => $days_diff);
            }
            $self->_set_modified;
            last;
        }
    }
}

sub _this_in {
    my $self = shift;

    if ($self->{tokens}->[$self->{index}+1] =~ $self->{data}->__this_in('hour')) {
        $self->{datetime}->add(hours => $self->{tokens}->[$self->{index}]);
        $self->_set_modified;
        return;
    }

    foreach my $key_weekday (keys %{$self->{data}->{weekdays}}) {
        my $weekday_short = lc(substr($key_weekday,0,3));
        if ($self->{tokens}->[$self->{index}] =~ /$key_weekday/i 
            || $self->{tokens}->[$self->{index}] eq $weekday_short) {
            my $days_diff = $self->{data}->{weekdays}->{$key_weekday} - $self->{datetime}->wday;
            $self->{datetime}->add(days => $days_diff);
            $self->{buffer} = '';
            $self->_set_modified;
            last;
        }

        if ($self->{tokens}->[$self->{index}] =~ $self->{data}->__this_in('week')) {
            my $weekday = ucfirst(lc($self->{tokens}->[$self->{index}-2]));
            my $days_diff = Decode_Day_of_Week($weekday) - $self->{datetime}->wday;
            $self->{datetime}->add(days => $days_diff);
            $self->{buffer} = '';
            $self->_set_modified;
            last;
        }

        foreach my $month (keys %{$self->{data}->{months}}) {
             if ($self->{tokens}->[$self->{index}] =~ /$month/i) {
                foreach my $weekday (keys %{$self->{data}->{weekdays}}) {
                    if ($self->{tokens}->[$self->{index}-2] =~ /$weekday/i) {

                        my ($often) = $self->{tokens}->[$self->{index}-3] =~ $self->{data}->__this_in('number');
                        my ($year, $month, $day) =
                        Nth_Weekday_of_Month_Year($self->{datetime}->year, $self->{data}->{months}->{$month}, 
                                                  $self->{data}->{weekdays}->{$weekday}, $often);
                        $self->{datetime}->set_year($year);
                        $self->{datetime}->set_month($month);
                        $self->{datetime}->set_day($day);

                        $self->_set_modified;
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
        my $weekday_short = lc(substr($key_weekday,0,3));

        if ($self->{tokens}->[$self->{index}] =~ /$key_weekday/i 
            || $self->{tokens}->[$self->{index}] eq $weekday_short) {
            my $days_diff = (7 - $self->{datetime}->wday) + Decode_Day_of_Week($key_weekday);
            $self->{datetime}->add(days => $days_diff);
            $self->{buffer} = '';
            $self->_set_modified;
            last;
        }

        if ($self->{tokens}->[$self->{index}] =~ $self->{data}->__next('week')) {
            my $weekday = ucfirst(lc($self->{tokens}->[$self->{index}-2]));
            my $days_diff = (7 - $self->{datetime}->wday) + Decode_Day_of_Week($weekday);
            $self->{datetime}->add(days => $days_diff);
            $self->{buffer} = '';
            $self->_set_modified;
            last;
        }

        if ($self->{tokens}->[$self->{index}] =~ $self->{data}->__next('month')) {
            $self->{datetime}->add(months => 1);
            if ($self->{tokens}->[$self->{index}-2] =~ $self->{data}->__next('day')) {
                my $day = $self->{tokens}->[$self->{index}-3];
                $day =~ s/$self->{data}->__next('number')/$1/ei;
                $self->{datetime}->set_day($day);
            }
            $self->_setmonthday;
            $self->{buffer} = '';
            $self->_set_modified;
            last;
        }

        if ($self->{tokens}->[$self->{index}] =~ $self->{data}->__next('year')) {
            $self->{datetime}->add(years => 1);
            if ($self->{tokens}->[$self->{index}-2] =~ $self->{data}->__next('month')) {
                my $month = $self->{tokens}->[$self->{index}-3];
                $month =~ s/$self->{data}->__next('number')/$1/ei;
                $self->{datetime}->set_month($month);
            }
            $self->_setyearday;
            $self->{buffer} = '';
            $self->_set_modified;
            last;
        }
    }
}

sub _last {
    my $self = shift;

    foreach my $key_weekday (keys %{$self->{data}->{weekdays}}) {
        my $weekday_short = lc(substr($key_weekday,0,3));

        if ($self->{tokens}->[$self->{index}] =~ /$key_weekday/i 
            || $self->{tokens}->[$self->{index}] eq $weekday_short) {
            my $days_diff = $self->{datetime}->wday + (7 - $self->{data}->{weekdays}->{$key_weekday});
            $self->{datetime}->subtract(days => $days_diff);
            $self->{buffer} = '';
            $self->_set_modified;
            last;
        }
    }

    if ($self->{tokens}->[$self->{index}] =~ $self->{data}->__last('week')) {
        if (exists $self->{data}->{weekdays}->{ucfirst(lc($self->{tokens}->[$self->{index}+1]))}) {
            $self->_setweekday($self->{index}+1);
        } elsif (exists $self->{data}->{weekdays}->{ucfirst(lc($self->{tokens}->[$self->{index}-2]))}) {
            $self->_setweekday($self->{index}-2);
        } elsif ($self->{tokens}->[$self->{index}-2] =~ $self->{data}->__last('day')) {
            my $days_diff = (7 + $self->{datetime}->wday);
            $self->{datetime}->subtract(days => $days_diff);
            my $day = $self->{tokens}->[$self->{index}-3];
            $day =~ s/$self->{data}->__last('number')/$1/ei;
            $self->{datetime}->add(days => $day);
            $self->{buffer} = '';
            $self->_set_modified;
        }
    }

    if ($self->{tokens}->[$self->{index}] =~ $self->{data}->__last('month')) {
        $self->{datetime}->subtract(months => 1);
        $self->_set_modified;
        if ($self->{tokens}->[$self->{index}-2] =~ $self->{data}->__last('day')) {
            my $day = $self->{tokens}->[$self->{index}-3];
            $day =~ s/$self->{data}->__last('number')/$1/ei;
            $self->{datetime}->set_day($day);
        }
        $self->{buffer} = '';
        $self->_setmonthday;
    }

    if ($self->{tokens}->[$self->{index}] =~ $self->{data}->__last('year')) {
        $self->{datetime}->subtract(years => 1);
        $self->_setyearday;
        $self->_set_modified;
        $self->{buffer} = '';
     }
}

sub _monthdays_limit {
    my $self = shift;

    my $monthdays = Days_in_Month($self->{datetime}->year, $self->{datetime}->month);

    if ($self->{datetime}->day > $monthdays) {
        $self->{datetime}->add(months => 1);
        $self->{datetime}->set_day($self->{datetime}->day - $monthdays);
        $self->_set_modified;
    } elsif ($self->{datetime}->day < 1) {
        $monthdays = Days_in_Month($self->{datetime}->year, ($self->{datetime}->month-1));
        $self->{datetime}->subtract(months => 1);
        $self->{datetime}->set_day($monthdays - $self->{datetime}->day);
        $self->_set_modified;
    }
}

sub _day {
    my $self = shift;

    if ($self->{tokens}->[$self->{index}] =~ $self->{data}->__day('init')) {
        if ($self->{tokens}->[$self->{index}] =~ $self->{data}->__day('yesterday')) {
            $self->{datetime}->subtract(days => 1);
        }
        my ($skip1, $skip2) = (0,0);
        if ($self->{tokens}->[$self->{index}] =~ $self->{data}->__day('tomorrow')) {
            if ($self->{lang} eq 'de') {
                if ($self->{tokens}->[$self->{index}] =~ $self->{data}->__day('morning_prefix')
                        || $self->{tokens}[$self->{index}-1] =~ $self->{data}->__day('at')
                        || $self->{tokens}[$self->{index}-1] =~ $self->{data}->__day('when')) {
                            $skip1 = 1;
                }
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

        $self->_set_modified;

        if ($self->{hours_before}) {
            $self->{datetime}->set_hour(24 - $self->{hours_before});
            if ($self->{tokens}->[$self->{index}+2] !~ $self->{data}->__day('noonmidnight')) {
                $self->{datetime}->subtract(days => 1);
            }
        } elsif ($self->{hours_after}) {
            $self->{datetime}->set_hour(0 + $self->{hours_after});
        }
    }

    if ($self->{datetime}->hour < 0) {
        my ($subtract) = $self->{datetime}->hour =~ /\-(.*)/;
        $self->{datetime}->set_hour(12 - $subtract);
    }
}

sub _setyearday {
    my $self = shift;

    if ($self->{tokens}->[$self->{index}-2] =~ $self->{data}->__setyearday('day')) {
        $self->{datetime}->set_month(1);
        my $days = $self->{tokens}->[$self->{index}-3];
        $days =~ s/$self->{data}->__setyearday('ext')/$1/ei;
        my ($year, $month, $day) = Add_Delta_Days($self->{datetime}->year, 1, 1, $days - 1);
        $self->{datetime}->set_day($day);
        $self->{datetime}->set_month($month);
        $self->{datetime}->set_year($year);
    }
}

sub _setmonthday {
    my $self = shift;

    foreach my $weekday (keys %{$self->{data}->{weekdays}}) {
        if ($self->{tokens}->[$self->{index}-2] =~ /$weekday/i) {
            my ($often) = $self->{tokens}->[$self->{index}-3] =~ /^(\d{1,2})(?:st|nd|rd|th)?$/i;
            my ($year, $month, $day) =
                Nth_Weekday_of_Month_Year($self->{datetime}->year, ($self->{datetime}->month),
                                          $self->{data}->{weekdays}->{$weekday}, $often);
            $self->{datetime}->set_year($year);
            $self->{datetime}->set_month($month);
            $self->{datetime}->set_day($day);
        }
    }
}

sub _setweekday {
    my ($self, $index) = @_;

    my $weekday = ucfirst(lc($self->{tokens}->[$index]));
    my $days_diff = $self->{datetime}->wday + (7 - $self->{data}->{weekdays}->{$weekday});
    $self->{datetime}->subtract(days => $days_diff);
    $self->{buffer} = '';
    $self->_set_modified;
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
