package DateTime::Format::Natural;

use strict;
use warnings;
use base qw(DateTime::Format::Natural::Base);

our $VERSION = '0.23_01';

sub new {
    my ($class, %opts) = @_;

    my $lang = $opts{lang} || 'en';
    my $mod  = __PACKAGE__.'::Lang::'.uc($lang);
    eval "use $mod";
    die $@ if $@;

    my $obj = {};
    $obj->{data} = $mod->__new();
    $obj->{lang} = $lang;

    return bless $obj, $class || ref($class);
}

sub parse_datetime {
    my $self = shift;

    my ($DEBUG, $date_string, %opts);

    if (@_ > 1) {
        %opts        = @_;
        $date_string = $opts{string};
        $DEBUG       = $opts{debug};
    } else {
        ($date_string) = @_;
    }

    unless ($self->{nodatetimeset}) {
        $self->{datetime} = DateTime->now(time_zone => 'local');
    }

    $date_string =~ tr/,//d;

    $self->{date_string} = $date_string;

    if ($date_string =~ m!/!) {
        my @bits = split '\/', $date_string;

        if (scalar @bits == 3) {
            $self->{datetime}->set_day($bits[0]);
            $self->{datetime}->set_month($bits[1]);
            $self->{datetime}->set_year($bits[2]);

            $self->_set_modified;

            return $self->_get_datetime_object;
        }
    } else {
        @{$self->{tokens}} = split ' ', $date_string;
    }

    my ($dont_proceed1, $dont_proceed2, $dont_proceed3) = (0,0,0);

    for ($self->{index} = 0; $self->{index} < @{$self->{tokens}}; $self->{index}++) {
        no warnings 'uninitialized';

        print "$self->{tokens}->[$self->{index}]\n" if $DEBUG;

        $self->{tokens}->[$self->{index}] =~ s/^(\d{1,2})(?:st|nd|rd|th)$/$1/i;

        if ($self->{tokens}->[$self->{index}] =~ $self->{data}->__main('second')) {
            $self->_set_modified;
        }

        if ($self->{tokens}->[$self->{index}+2] =~ $self->{data}->__main('ago')) {
            $self->_ago;
        }

        if ($self->{tokens}->[$self->{index}+3] =~ $self->{data}->__main('now')) {
            $self->_now;
        }

        foreach my $daytime (@{$self->{data}->__main('daytime')}) {
            if ($self->{tokens}->[$self->{index}] =~ $daytime) {
                $self->_daytime;
            }
        }

        if ($self->{tokens}->[$self->{index}+1] =~ /^(\d{4})$/) {
            $self->{datetime}->set_year($1);
        }

        OUTER1: foreach my $match (@{$self->{data}->__main('months')}) {
            foreach my $i qw(-1 0 1 2) {
                if ($self->{tokens}->[$self->{index}+$i] =~ /^$match$/i) {
                    $dont_proceed1 = 1;
                    last OUTER1;
                }
            }
        }

       unless ($dont_proceed1) {
            $self->_months;
       }

       if ($self->{tokens}->[$self->{index}] =~ /^at$/i) {
           next;
       } elsif ($self->{tokens}->[$self->{index}] =~ $self->{data}->__main('at_intro')) {
        OUTER2: foreach my $match (@{$self->{data}->__main('at_matches')}) {
                foreach my $i qw(-1 0 1 2) {
                    if ($self->{tokens}->[$self->{index}+$i] =~ /^$match$/i) {
                        $dont_proceed2 = 1;
                        last OUTER2;
                    }
                }
            }
            unless ($dont_proceed2) {
                $self->_at($1, $2, $3, $4);
            }
        }

        if ($self->{tokens}->[$self->{index}] =~ $self->{data}->__main('number_intro')) {
            OUTER3: foreach my $match (@{$self->{data}->__main('number_matches')}) {
                foreach my $i qw(-1 0 1 2) {
                    if ($self->{tokens}->[$self->{index}+$i] =~ /^$match$/i) {
                       $dont_proceed3 = 1;
                       last OUTER3;
                    }
                }
            }
            OUTER4: foreach my $weekday (keys %{$self->{data}->{weekdays}}) {
                if ($self->{tokens}->[$self->{index}+1] =~ /^$weekday$/i) {
                    $dont_proceed3 = 1;
                    last OUTER4;
                }
            }
            unless ($dont_proceed3) {
                $self->_number($1);
            }
        }

        if ($self->{tokens}->[$self->{index}] =~ /^\d{4}$/) {
            $self->{datetime}->set_year($self->{tokens}->[$self->{index}]);
        }

        if ($self->{tokens}->[$self->{index}]      !~ $self->{data}->__main('weekdays')
            && $self->{tokens}->[$self->{index}-1] !~ $self->{data}->__main('weekdays')
            && $self->{tokens}->[$self->{index}-2] !~ $self->{data}->__main('weekdays')
            && $self->{tokens}->[$self->{index}+1] !~ $self->{data}->__main('weekdays')) {
            $self->_weekday;

        }

        if ($self->{tokens}->[$self->{index}] =~ $self->{data}->__main('this_in')) {
            $self->{buffer} = 'this_in';
            next;
        } elsif ($self->{buffer} eq 'this_in') {
            $self->_this_in;
        }

        if ($self->{tokens}->[$self->{index}] =~ $self->{data}->__main('next')) {
            $self->{buffer} = 'next';
            next;
        } elsif ($self->{buffer} eq 'next') {
            $self->_next;
        }

        if ($self->{tokens}->[$self->{index}] =~ $self->{data}->__main('last')) {
            $self->{buffer} = 'last';
            next;
        } elsif ($self->{buffer} eq 'last') {
            $self->_last;
        }

        $self->_day;
        $self->_monthdays_limit;
    }

    return $self->_get_datetime_object;
}

sub _get_modified   { $_[0]->{modified}     }
sub _set_modified   { $_[0]->{modified} = 1 }
sub _unset_modified { $_[0]->{modified} = 0 }

sub _get_datetime_object {
    my $self = shift;

    die "$self->{date_string} not valid input, exiting.\n" unless $self->_get_modified;

    $self->{year}  = $self->{datetime}->year;
    $self->{month} = $self->{datetime}->month;
    $self->{day}   = $self->{datetime}->day_of_month;
    $self->{hour}  = $self->{datetime}->hour;
    $self->{min}   = $self->{datetime}->minute;
    $self->{sec}   = $self->{datetime}->second;

    $self->{sec}   = "0$self->{sec}"   unless length($self->{sec})   == 2;
    $self->{min}   = "0$self->{min}"   unless length($self->{min})   == 2;
    $self->{hour}  = "0$self->{hour}"  unless length($self->{hour})  == 2;
    $self->{day}   = "0$self->{day}"   unless length($self->{day})   == 2;
    $self->{month} = "0$self->{month}" unless length($self->{month}) == 2;

    $self->_unset_modified;

    my $dt = DateTime->new(year   => $self->{year},
                           month  => $self->{month},
                           day    => $self->{day},
                           hour   => $self->{hour},
                           minute => $self->{min},
                           second => $self->{sec});
    return $dt;
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

 $parse = DateTime::Format::Natural->new(lang => '[en|de]');

C<lang> contains the language selected, currently limited to
C<en> (english) & C<de> (german).

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

=head1 SEE ALSO

L<DateTime>, L<Date::Calc>, L<http://datetime.perl.org>

=head1 AUTHOR

Steven Schubiger <schubiger@cpan.org>

=head1 LICENSE

This program is free software; you may redistribute it and/or
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
