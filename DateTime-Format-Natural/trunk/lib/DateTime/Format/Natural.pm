package DateTime::Format::Natural;

use strict;
use warnings;
use base qw(DateTime::Format::Natural::Base);

use List::MoreUtils qw(any none);

our $VERSION = '0.27';

sub new {
    my ($class, %opts) = @_;

    my $lang = $opts{lang} || 'en';
    my $mod  = __PACKAGE__.'::Lang::'.uc($lang);

    eval "use $mod";
    die $@ if $@;

    my $obj = {};

    $obj->{data}   = $mod->__new();
    $obj->{format} = $opts{format} || 'd/m/y';
    $obj->{lang}   = $lang;

    return bless $obj, $class || ref($class);
}

sub parse_datetime {
    my $self = shift;

    my ($date_string, %opts);

    if (@_ > 1) {
        %opts          = @_;
        $date_string   = $opts{string};
        $self->{Debug} = $opts{debug};
    } else {
        ($date_string) = @_;
    }

    unless ($self->{nodatetimeset}) {
        $self->{datetime} = DateTime->now(time_zone => 'local');
    }

    $self->_flush_datetime_objects;

    my @date_strings = $date_string =~ /to/i
      ? split /\s+ to \s+/ix, $date_string
      : ($date_string);

    foreach $date_string (@date_strings) {
        $date_string =~ tr/,//d;

        $self->{date_string} = $date_string;

        if ($date_string =~ m!(?:/|\-)!) {
            my $separator = $date_string =~ m!/! ? '/' : '-';
               $separator = quotemeta $separator;

            my @separated_order = split $separator, $self->{format};
            my $separated_index = 0;

            $self->{_separated_indices} = { map { substr($_, 0, 1) => $separated_index++ } @separated_order };

            my @bits = split $separator, $date_string;

            my @time    = localtime;
            my $century = substr($time[5] + 1900, 0, 2);

            if ($bits[$self->{_separated_indices}->{y}] > $century) { $century-- }

            my $year = $bits[$self->{_separated_indices}->{y}];
               $year = "$century$year" if length $year == 2;

            if (@bits == 3) {
                $self->{datetime}->set_day  ($bits[$self->{_separated_indices}->{d}]);
                $self->{datetime}->set_month($bits[$self->{_separated_indices}->{m}]);
                $self->{datetime}->set_year ($year);

                $self->{tokens_count} = 3;
                $self->_set_modified(3);

                $self->_save_datetime_object;

                return $self->_get_datetime_objects;
            }
        } else {
            @{$self->{tokens}}    = split ' ', $date_string;
            $self->{tokens_count} = scalar @{$self->{tokens}};
        }

        $self->_process;
    }

    return $self->_get_datetime_objects;
}

sub _process {
    my $self = shift;

    for ($self->{index} = 0;
         $self->{index} < @{$self->{tokens}};
         $self->{index}++) {

        $self->_debug_head;

        $self->_process_numify;
        $self->_process_second;
        $self->_process_ago;
        $self->_process_now;
        $self->_process_daytime;
        $self->_process_year;
        $self->_process_months;
        $self->_process_at;
        $self->_process_number;
        $self->_process_weekday;
        $self->_process_this_in;
        $self->_process_next;
        $self->_process_last;
        $self->_process_day;
        $self->_process_monthdays_limit;
    }

    $self->_save_datetime_object;
}

sub _debug_head {
    my $self = shift;

    print "$self->{tokens}->[$self->{index}]\n" if $self->{Debug};
}

sub _process_numify {
    my $self = shift;

    $self->{tokens}->[$self->{index}] =~ s/^(\d{1,2})(?:st|nd|rd|th)$/$1/i;
}

sub _process_second {
    my $self = shift;

    if ($self->{tokens}->[$self->{index}] =~ $self->{data}->__main('second')) {
        $self->_set_modified(1);
    }
}

sub _process_ago {
    my $self = shift;

    if ($self->{tokens}->[$self->{index}+2] =~ $self->{data}->__main('ago')) {
        $self->_ago;
    }
}

sub _process_now {
    my $self = shift;

    if ($self->{tokens}->[$self->{index}+3] =~ $self->{data}->__main('now')) {
        $self->_now;
    }
}

sub _process_daytime {
    my $self = shift;

    foreach my $daytime (@{$self->{data}->__main('daytime')}) {
        if ($self->{tokens}->[$self->{index}] =~ $daytime) {
            $self->_daytime;
        }
    }
}

sub _process_year {
    my $self = shift;

    foreach my $token (@{$self->{tokens}}) {
        if ($token =~ /^(\d{4})$/) {
            $self->{datetime}->set_year($1);
            $self->_set_modified(1);
        }
    }
}

sub _process_months {
    my $self = shift;

    my $dont_proceed;

    foreach my $match (@{$self->{data}->__main('months')}) {
        if (any { /^$match$/i } @{$self->{tokens}}) {
            $dont_proceed = 1;
            last;
        }
    }

    $self->_months unless $dont_proceed;
}

sub _process_at {
    my $self = shift;

    if ($self->{tokens}->[$self->{index}] =~ /^at$/i) {
        return;
    } elsif ($self->{tokens}->[$self->{index}] =~ $self->{data}->__main('at_intro')) {
        my $dont_proceed;

        foreach my $match (@{$self->{data}->__main('at_matches')}) {
            if (any { /^$match$/i } @{$self->{tokens}}) {
                $dont_proceed = 1;
                last;
            }
        }

        $self->_at($1,$2,$3,$4) unless $dont_proceed;
    }
}

sub _process_number {
    my $self = shift;

    if ($self->{tokens}->[$self->{index}] =~ $self->{data}->__main('number_intro')) {
        my $dont_proceed;

        foreach my $match (@{$self->{data}->__main('number_matches')}) {
            if (any { /^$match$/i } @{$self->{tokens}}) {
                $dont_proceed = 1;
                last;
            }
        }

        foreach my $weekday (keys %{$self->{data}->{weekdays}}) {
            if ($self->{tokens}->[$self->{index}+1] =~ /^$weekday$/i) {
                $dont_proceed = 1;
                last;
            }
        }

        $self->_number($1) unless $dont_proceed;
    }
}

sub _process_weekday {
    my $self = shift;

    if (none { /$self->{data}->__main('weekdays')/ } @{$self->{tokens}}) {
        $self->_weekday;
    }
}

sub _process_this_in {
    my $self = shift;

    if ($self->{tokens}->[$self->{index}] =~ $self->{data}->__main('this_in')) {
        $self->{buffer} = 'this_in';
        return;
    } elsif ($self->{buffer} eq 'this_in') {
        $self->_this_in;
    }
}

sub _process_next {
    my $self = shift;

    if ($self->{tokens}->[$self->{index}] =~ $self->{data}->__main('next')) {
        $self->{buffer} = 'next';
        return;
    } elsif ($self->{buffer} eq 'next') {
        $self->_next;
    }
}

sub _process_last {
    my $self = shift;

    if ($self->{tokens}->[$self->{index}] =~ $self->{data}->__main('last')) {
        $self->{buffer} = 'last';
        return;
    } elsif ($self->{buffer} eq 'last') {
        $self->_last;
    }
}

sub _process_day {
    my $self = shift;

    $self->_day;
}

sub _process_monthdays_limit {
    my $self = shift;

    $self->_monthdays_limit;
}

sub _get_modified   { $_[0]->{modified}          }
sub _set_modified   { $_[0]->{modified} += $_[1] }
sub _unset_modified { $_[0]->{modified}  = 0     }

sub _flush_datetime_objects {
    my $self = shift;

    undef @{$self->{stack}};
}

sub _save_datetime_object {
    my $self = shift;

    die "$self->{date_string} not valid input, exiting.\n"
         unless $self->_get_modified >= $self->{tokens_count};

    $self->{year}  = $self->{datetime}->year;
    $self->{month} = $self->{datetime}->month;
    $self->{day}   = $self->{datetime}->day_of_month;
    $self->{hour}  = $self->{datetime}->hour;
    $self->{min}   = $self->{datetime}->minute;
    $self->{sec}   = $self->{datetime}->second;

    $self->{sec}   = sprintf("%02i", $self->{sec});
    $self->{min}   = sprintf("%02i", $self->{min});
    $self->{hour}  = sprintf("%02i", $self->{hour});
    $self->{day}   = sprintf("%02i", $self->{day});
    $self->{month} = sprintf("%02i", $self->{month});

    $self->_unset_modified;

    my $dt = DateTime->new(year   => $self->{year},
                           month  => $self->{month},
                           day    => $self->{day},
                           hour   => $self->{hour},
                           minute => $self->{min},
                           second => $self->{sec});

    push @{$self->{stack}}, $dt;
}

sub _get_datetime_objects {
    my $self = shift;

    return @{$self->{stack}};
}

# solely for debugging purpose
sub _set_datetime {
    my ($self, $year, $month, $day, $hour, $min) = @_;

    $self->{datetime} = DateTime->now(time_zone => 'local');

    $self->{nodatetimeset} = 1;

    $self->{datetime}->set_year($year);
    $self->{datetime}->set_month($month);
    $self->{datetime}->set_day($day);
    $self->{datetime}->set_hour($hour);
    $self->{datetime}->set_minute($min);
}

1;
__END__

=head1 NAME

DateTime::Format::Natural - Create machine readable date/time with natural parsing logic

=head1 SYNOPSIS

 use DateTime::Format::Natural;

 $parse = DateTime::Format::Natural->new;

 $dt = $parse->parse_datetime($date_string);

=head1 DESCRIPTION

C<DateTime::Format::Natural> consists of a method, C<parse_datetime>, which takes a
string with a human readable date/time and creates a machine readable one by applying
natural parsing logic.

=head1 FUNCTIONS

=head2 new

Creates a new DateTime::Format::Natural object.

 $parse = DateTime::Format::Natural->new(lang => '[en|de]', format => 'mm/dd/yy');

C<lang> contains the language selected, currently limited to C<en> (english) & C<de>
(german), defaults to 'en'. C<format> specifices to format of numeric dates, defaults
to 'd/m/y'.

=head2 parse_datetime

Creates a C<DateTime> object from a human readable date/time string.

 $dt = $parse->parse_datetime($date_string);

 $dt = $parse->parse_datetime(string => $date_string, debug => 1);

The options may contain the keys C<string> & C<debug>. C<string> may consist of the
datestring, whereas C<debug> holds the boolean value for the debugging option. If
debugging is enabled, each token that is analysed will be output to STDOUT with a
trailing newline appended.

The C<string> parameter is required.

Returns a C<DateTime> object.

=head2 format_datetime

Not implemented yet.

=head1 EXAMPLES

See the modules C<DateTime::Format::Natural::Lang::*> for a overview of valid input.

=head1 CREDITS

Thanks to Tatsuhiko Miyagawa for the initial inspiration. See Miyagawa's journal
entry L<http://use.perl.org/~miyagawa/journal/31378> for more information.

Furthermore, thanks to (in order of appearance)

 Clayton L. Scott
 Dave Rolsky
 CPAN Author 'SEKIMURA'
 mike (pulsation)
 Mark Stosberg

=head1 SEE ALSO

L<DateTime>, L<Date::Calc>, L<http://datetime.perl.org>

=head1 AUTHOR

Steven Schubiger <schubiger@cpan.org>

=head1 LICENSE

This program is free software; you may redistribute it and/or
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
