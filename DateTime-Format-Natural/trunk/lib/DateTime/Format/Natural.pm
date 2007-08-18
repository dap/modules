package DateTime::Format::Natural;

use strict;
use warnings;
use base qw(DateTime::Format::Natural::Base);

use Carp ();
use List::MoreUtils qw(any none);

our $VERSION = '0.34';

sub new {
    my $class = shift;

    my $self = bless {}, ref($class) || $class;
    $self->_init(@_);

    return $self;
}

sub _init {
    my ($self, %opts) = @_;

    $self->{Format}        = $opts{format}  || 'd/m/y';
    $self->{Lang}          = $opts{lang}    || 'en';
    $self->{Opts}{daytime} = $opts{daytime};

    $self->_init_check;
    $self->_init_vars;

    my $mod  = __PACKAGE__.'::Lang::'.uc($self->{Lang});
    eval "use $mod"; die $@ if $@;

    $self->{data} = $mod->__new();

    return $self;
}

sub _init_check {
    my $self = shift;

    my %re = (format => qr!^(?:[dmy]{1,4}[-./]){2}[dmy]{1,4}$!i,
              lang   => qr!^(?:en|de)$!);

    my %msg = (format => 'format string has no valid format',
               lang   => 'language is not supported');

    my $error;
    foreach my $lookup (keys %re) {
        my $param = ucfirst $lookup;
        unless ($self->{$param} =~ $re{$lookup}) {
            $error = "parameter '$param': $msg{$lookup}";
            last;
        }
    }

    Carp::croak "new(): $error\n" if defined $error;
}

sub _init_vars {
    my $self = shift;

    $self->{buffer} = '';
}

sub parse_datetime {
    my $self = shift;

    $self->_parse_init(@_);

    my $date_string = $self->{Date_string};
    $date_string =~ tr/,//d;

    my @count = $date_string =~ m![-./]!g;
    my %count; $count{$_}++ foreach @count;

    if (scalar keys %count == 1 && $count{(keys %count)[0]} == 2) {
        $self->{tokens_count} = 1;

        my $separator =  $self->{Format};
        $separator    =~ tr/a-zA-Z//d;
        $separator    =~ tr/a-zA-Z//cs;
        $separator    =  quotemeta $separator;

        my @separated_order = split $separator, $self->{Format};
        my $separated_index = 0;

        my $separated_indices = { map { substr($_, 0, 1) => $separated_index++ } @separated_order };

        my @bits = split $separator, $date_string;

        my @time    = localtime;
        my $century = substr($time[5] + 1900, 0, 2);

        if ($bits[$separated_indices->{y}] > $century) { $century-- }

        my $year = $bits[$separated_indices->{y}];
           $year = "$century$year" if length $year == 2;

        $self->{datetime}->set_day  ($bits[$separated_indices->{d}]);
        $self->{datetime}->set_month($bits[$separated_indices->{m}]);
        $self->{datetime}->set_year ($year);

        $self->_set_modified(1);
    } else {
        @{$self->{tokens}} = split ' ', $date_string;
        $self->{data}->__init('tokens')->($self);
        $self->{tokens_count} = scalar @{$self->{tokens}};

        $self->_process;
    }

    return $self->_get_datetime_object;
}

sub _parse_init {
    my $self = shift;

    if (@_ > 1) {
        my %opts             = @_;
        $self->{Date_string} = $opts{string};
        $self->{Debug}       = $opts{debug};
    } else {
        ($self->{Date_string}) = @_;
    }

    unless ($self->{nodatetimeset}) {
        $self->{datetime} = DateTime->now(time_zone => 'floating');
    }

    $self->_unset_failure;
    $self->_unset_error;
    $self->_unset_modified;
}

sub parse_datetime_duration {
    my $self = shift;

    $self->_parse_init(@_);

    my $timespan_sep = $self->{data}->__timespan('literal');

    my @date_strings = $self->{Date_string} =~ /$timespan_sep/i
      ? split /\s+ $timespan_sep \s+/ix, $self->{Date_string}
      : ($self->{Date_string});

    my @stack;
    foreach my $date_string (@date_strings) {
        push @stack, $self->parse_datetime($date_string);
    }

    return @stack;
}

sub success {
    my $self = shift;

    return ($self->_get_modified >= $self->{tokens_count})
        && !$self->_get_failure ? 1 : 0;
}

sub error {
    my $self = shift;

    return '' if $self->success;

    my $error  = "'$self->{Date_string}' does not parse ";
       $error .= $self->_get_error || '(perhaps you have some garbage?)';

    return $error;
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
}

sub _debug_head {
    my $self = shift;

    print ${$self->_token(0)}, "\n" if $self->{Debug};
}

sub _process_numify {
    my $self = shift;

    ${$self->_token(0)} =~ s/^(\d{1,2})(?:st|nd|rd|th)$/$1/i;
}

sub _process_second {
    my $self = shift;

    if (${$self->_token(0)} =~ $self->{data}->__main('second')) {
        $self->_set_modified(1);
    }
}

sub _process_ago {
    my $self = shift;

    if (${$self->_token(2)} =~ $self->{data}->__main('ago')) {
        $self->_ago;
    }
}

sub _process_now {
    my $self = shift;

    if (${$self->_token(3)} =~ $self->{data}->__main('now')) {
        $self->_now;
    }
}

sub _process_daytime {
    my $self = shift;

    foreach my $daytime (@{$self->{data}->__main('daytime')}) {
        if (${$self->_token(0)} =~ $daytime) {
            $self->_daytime;
        }
    }
}

sub _process_year {
    my $self = shift;

    foreach my $token (@{$self->{tokens}}) {
        if (my ($year) = $token =~ /^(\d{4})$/) {
            $self->{datetime}->set_year($year);
            $self->_set_modified(1);
        }
    }
}

sub _process_months {
    my $self = shift;

    foreach my $match (@{$self->{data}->__main('months')}) {
        if (any { /^$match$/i } @{$self->{tokens}}) {
            return;
        }
    }

    $self->_months;
}

sub _process_at {
    my $self = shift;

    if (${$self->_token(0)} =~ /^at$/i) {
        return;
    } elsif (${$self->_token(0)} =~ $self->{data}->__main('at_intro')) {
        my @matches = ($1, $2, $3, $4);

        foreach my $match (@{$self->{data}->__main('at_matches')}) {
            if (any { /^$match$/i } @{$self->{tokens}}) {
                return;
            }
        }

        $self->_at(@matches);
    }
}

sub _process_number {
    my $self = shift;

    if (${$self->_token(0)} =~ $self->{data}->__main('number_intro')) {
        my $match = $1;

        foreach my $match (@{$self->{data}->__main('number_matches')}) {
            if (any { /^$match$/i } @{$self->{tokens}}) {
                return;
            }
        }

        foreach my $weekday (keys %{$self->{data}->{weekdays}}) {
            if (${$self->_token(1)} =~ /^$weekday$/i) {
                return;
            }
        }

        $self->_number($match);
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

    if (${$self->_token(0)} =~ $self->{data}->__main('this_in')) {
        $self->{buffer} = 'this_in';
        return;
    } elsif ($self->{buffer} eq 'this_in') {
        $self->_this_in;
    }
}

sub _process_next {
    my $self = shift;

    if (${$self->_token(0)} =~ $self->{data}->__main('next')) {
        $self->{buffer} = 'next';
        return;
    } elsif ($self->{buffer} eq 'next') {
        $self->_next;
    }
}

sub _process_last {
    my $self = shift;

    if (${$self->_token(0)} =~ $self->{data}->__main('last')) {
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

sub _token {
    my ($self, $pos) = @_;

    my $str = '';

    return defined $self->{tokens}->[$self->{index} + $pos]
      ? \$self->{tokens}->[$self->{index} + $pos]
      : \$str;
}

sub _get_error      { $_[0]->{error}             }
sub _set_error      { $_[0]->{error} = $_[1]     }
sub _unset_error    { $_[0]->{error} = ''        }

sub _get_failure    { $_[0]->{failure}           }
sub _set_failure    { $_[0]->{failure} = 1       }
sub _unset_failure  { $_[0]->{failure} = 0       }

sub _get_modified   { $_[0]->{modified} || 0     }
sub _set_modified   { $_[0]->{modified} += $_[1] }
sub _unset_modified { $_[0]->{modified}  = 0     }

sub _get_datetime_object {
    my $self = shift;

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
    my ($self, $year, $month, $day, $hour, $min, $sec) = @_;

    $self->{datetime} = DateTime->now(time_zone => 'floating');

    $self->{nodatetimeset} = 1;

    $self->{datetime}->set_year($year);
    $self->{datetime}->set_month($month);
    $self->{datetime}->set_day($day);
    $self->{datetime}->set_hour($hour);
    $self->{datetime}->set_minute($min);
    $self->{datetime}->set_second($sec);
}

1;
__END__

=head1 NAME

DateTime::Format::Natural - Create machine readable date/time with natural parsing logic

=head1 SYNOPSIS

 use DateTime::Format::Natural;

 $parser = DateTime::Format::Natural->new;

 $dt = $parser->parse_datetime($date_string);
 @dt = $parser->parse_datetime_duration($date_string);

 if ($parser->success) {
     # operate on $dt/@dt, for example:
     printf("%02s.%02s.%4s %02s:%02s:%02s\n", $dt->day,
                                              $dt->month,
                                              $dt->year,
                                              $dt->hour,
                                              $dt->min,
                                              $dt->sec);
 } else {
     warn $parser->error;
 }

=head1 DESCRIPTION

C<DateTime::Format::Natural> takes a string with a human readable date/time and creates a
machine readable one by applying natural parsing logic.

=head1 METHODS

=head2 new

Creates a new C<DateTime::Format::Natural> object. Arguments to C<new()> are options and
not necessarily required.

 $parser = DateTime::Format::Natural->new(
           lang    => '[en|de]',
           format  => 'mm/dd/yy',
           daytime => { morning   => 06,
                        afternoon => 13,
                        evening   => 20,
                      },
 );

=over 4

=item lang

Contains the language selected, currently limited to C<en> (english) & C<de> (german).
Defaults to 'C<en>'.

=item format

Specifies the format of numeric dates, defaults to 'C<d/m/y>'.

=item daytime

A hash consisting of specific hours given for peculiar daytimes. Daytimes may be
selectively changed.

=back

=head2 parse_datetime

Creates a C<DateTime> object from a human readable date/time string.

 $dt = $parser->parse_datetime($date_string);

 $dt = $parser->parse_datetime(
       string => $date_string,
       debug  => 1,
 );

=over 4

=item string

The date string.

=item debug

Boolean value indicating debugging mode.

If debugging is enabled, each token that is analysed will be output to STDOUT
with a trailing newline appended.

=back

Returns a L<DateTime> object.

=head2 parse_datetime_duration

Creates one or more C<DateTime> object(s) from a human readable date/time string
which may contain timespans/durations. 'Same' interface & options as parse_datetime(),
but must be explicitly called in list context.

 @dt = $parser->parse_datetime_duration($date_string);

 @dt = $parser->parse_datetime_duration(
       string => $date_string,
       debug  => 1,
 );

=head2 success

Returns a boolean indicating success or failure for parsing the date/time
string given.

=head2 error

Returns the error message if the parsing didn't succeed.

=head1 EXAMPLES

See the modules C<DateTime::Format::Natural::Lang::*> for a overview of valid input.

=head1 CREDITS

Thanks to Tatsuhiko Miyagawa for the initial inspiration. See Miyagawa's journal
entry L<http://use.perl.org/~miyagawa/journal/31378> for more information.

Furthermore, thanks to (in order of appearance) who have contributed
valuable suggestions & patches:

 Clayton L. Scott
 Dave Rolsky
 CPAN Author 'SEKIMURA'
 mike (pulsation)
 Mark Stosberg
 Tuomas Jormola
 Cory Watson
 Urs Stotz

=head1 SEE ALSO

L<DateTime>, L<Date::Calc>, L<http://datetime.perl.org>

=head1 AUTHOR

Steven Schubiger <schubiger@cpan.org>

=head1 LICENSE

This program is free software; you may redistribute it and/or
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
