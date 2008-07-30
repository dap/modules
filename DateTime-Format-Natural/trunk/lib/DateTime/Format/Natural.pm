package DateTime::Format::Natural;

use strict;
use warnings;
use base qw(DateTime::Format::Natural::Base);

use Carp qw(croak);
use DateTime ();
use Date::Calc qw(Day_of_Week check_date);
use List::MoreUtils qw(all any);
use Params::Validate ':all';

our $VERSION = '0.71_01';

sub new
{
    my $class = shift;

    my $self = bless {}, ref($class) || $class;

    $self->_init_check(@_);
    $self->_init(@_);

    return $self;
}

sub _init
{
    my ($self, %opts) = @_;

    $self->{Format}        = $opts{format}        || 'd/m/y';
    $self->{Lang}          = $opts{lang}          || 'en';
    $self->{Prefer_future} = $opts{prefer_future} || 0;
    $self->{Time_zone}     = $opts{time_zone}     || 'floating';
    $self->{Opts}{daytime} = $opts{daytime};

    my $mod = __PACKAGE__.'::Lang::'.uc($self->{Lang});
    eval "use $mod"; die $@ if $@;

    $self->{data} = $mod->__new();
    $self->{grammar_class} = $mod;
}

sub _init_check
{
    my $self = shift;

    validation_options(
        on_fail => sub
    {
        my ($error) = @_;
        chomp $error;
        croak $error;
    },
        stack_skip => 2,
    );

    validate(@_, {
        lang => {
            type => SCALAR,
            optional => 1,
            regex => qr!^(?:en)$!,
        },
        format => {
            type => SCALAR,
            optional => 1,
            regex => qr!^(?:[dmy]{1,4}[-./]){2}[dmy]{1,4}$!i,
        },
        prefer_future => {
            type => SCALAR,
            optional => 1,
            regex => qr!^[01]$!,
        },
        time_zone => {
            type => SCALAR,
            optional => 1,
            callbacks => {
                'valid timezone' => sub
                {
                    eval { DateTime::TimeZone->new(name => shift) };
                    !$@;
                }
            }
        },
        daytime => {
            type => HASHREF,
            optional => 1,
        },
    });
}

sub _init_vars
{
    my $self = shift;

    delete $self->{modified};
    delete $self->{postprocess};
}

sub parse_datetime
{
    my $self = shift;

    $self->_parse_init(@_);

    my $date_string = $self->{Date_string};
    $date_string =~ tr/,//d;

    my @count = $date_string =~ m![-./]!g;
    my %count; $count{$_}++ foreach @count;

    if (scalar keys %count == 1 && $count{(keys %count)[0]} == 2) {
        if ($date_string =~ /^\S+\b\s+\b\S+/) {
            ($date_string, @{$self->{tokens}}) = split /\s+/, $date_string;
            $self->{count}{tokens} = 1 + @{$self->{tokens}};
        }
        else {
            $self->{count}{tokens} = 1;
        }

        my $separator = quotemeta((keys %count)[0]);
        my @chunks = split /$separator/, $date_string;

        my $i = 0;
        my %length = map { length $_ => $i++ } @chunks;

        my $format = $self->{Format};

        if (exists $length{4}) {
            $format = join $separator, ($length{4} == 0 ? qw(yyyy mm dd) : qw(dd mm yyyy));
        }
        else {
            $separator = do { local $_ = $format;
                              tr/a-zA-Z//d;
                              tr/a-zA-Z//cs;
                              quotemeta; };
        }

        my @separated_order = split /$separator/, $format;
        my $separated_index = 0;

        my $separated_indices = { map { substr($_, 0, 1) => $separated_index++ } @separated_order };

        my @bits = split $separator, $date_string;

        my $century = $self->{datetime}
                    ? int($self->{datetime}->year / 100)
                    : substr((localtime)[5] + 1900, 0, 2);

        my ($day, $month, $year) = map { $bits[$separated_indices->{$_}] } qw(d m y);

        if (not defined $day && defined $month && defined $year) {
            $self->_set_failure;
            $self->_set_error("('format' parameter invalid)");
            return $self->_get_datetime_object;
        }

        if ($year > $century) { $century-- };
        if (length $year == 2) { $year = "$century$year" };

        unless (check_date($year, $month, $day)) {
            $self->_set_failure;
            $self->_set_error("(invalid date)");
            return $self->_get_datetime_object;
        }

        $self->{datetime}->set_year($year);
        $self->{datetime}->set_month($month);
        $self->{datetime}->set_day($day);

        $self->_set_valid_exp;
        $self->_set_modified(1);

        if (@{$self->{tokens} || []}) {
            $self->_unset_valid_exp;
            $self->_unset_modified;
            $self->_process;
        }
    }
    else {
        @{$self->{tokens}} = split ' ', $date_string;
        $self->{data}->__init('tokens')->($self);
        $self->{count}{tokens} = scalar @{$self->{tokens}};

        $self->_process;
    }

    return $self->_get_datetime_object;
}

sub _parse_init
{
    my $self = shift;

    if (@_ > 1) {
        validate(@_, { string => 1 });
        my %opts             = @_;
        $self->{Date_string} = $opts{string};
        (undef)              = $opts{debug}; # legacy
    }
    else {
        validate_pos(@_, 1);
        ($self->{Date_string}) = @_;
    }

    unless ($self->{running_tests}) {
        $self->{datetime} = DateTime->now(time_zone => $self->{Time_zone});
    }

    $self->_init_vars;

    $self->_unset_failure;
    $self->_unset_error;
    $self->_unset_valid_exp;
    $self->_unset_trace;
    $self->_unset_modified;
}

sub parse_datetime_duration
{
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

sub success
{
    my $self = shift;

    return ($self->_get_valid_exp && !$self->_get_failure) ? 1 : 0;
}

sub error
{
    my $self = shift;

    return '' if $self->success;

    my $error  = "'$self->{Date_string}' does not parse ";
       $error .= $self->_get_error || '(perhaps you have some garbage?)';

    return $error;
}

sub trace
{
    my $self = shift;

    my @modified;
    foreach my $unit (grep { $_ ne 'total' } keys %{$self->{modified}}) {
        push @modified, "$unit: $self->{modified}{$unit}";
    }

    return join "\n", @{$self->{trace}}, @modified;
}

sub _process
{
    my $self = shift;

    PARSE: foreach my $keyword (keys %{$self->{data}->__grammar('')}) {
        my @grammar = @{$self->{data}->__grammar($keyword)};
        my $types = shift @grammar;

        next if @{$self->{tokens}} > @$types;
        last if $self->_get_modified >= @{$self->{tokens}};

        foreach my $expression (@grammar) {
            my $valid_expression = 1;
            my $definition = $expression->[0];
            my @positions = keys %$definition;
            my %regex_stack;
            foreach my $pos (@positions) {
                if ($types->[$pos] eq 'SCALAR') {
                    if (defined $definition->{$pos}) {
                        if (${$self->_token($pos)} =~ /^$definition->{$pos}$/i) {
                            next;
                        }
                        else {
                            $valid_expression = 0;
                        }
                    }
                }
                elsif ($types->[$pos] eq 'REGEXP') {
                    local $1;
                    if (${$self->_token($pos)} =~ $definition->{$pos}) {
                        $regex_stack{$pos} = $1 if defined $1;
                        next;
                    }
                    else {
                        $valid_expression = 0;
                    }
                }
                else {
                    die "grammar error at keyword \"$keyword\" within $self->{grammar_class}: ",
                        "unknown type $types->[$pos]\n";
                }
            }
            if ($valid_expression) {
                $self->_set_valid_exp;
                my $i;
                foreach my $positions (@{$expression->[1]}) {
                    my @values;
                    foreach my $pos (@$positions) {
                        $values[$pos] = exists $regex_stack{$pos}
                          ? $regex_stack{$pos}
                          : ${$self->_token($pos)};
                    }
                    @values = map { defined $_ ? $_ : () } @values;
                    my $meth = 'SUPER::'.$expression->[-1]->[$i++];
                    $self->$meth(@values);
                }
                last PARSE;
            }
        }
    }

    $self->_post_process_options;
}

sub _post_process_options
{
    my $self = shift;

    if ($self->{Prefer_future}) {
        my %modified = map { $_ => 1 } grep { $_ ne 'total' } keys %{$self->{modified}};

        if ($self->{count}{tokens} == 1
            && (any { $self->{tokens}->[0] =~ /$_/i } @{$self->{data}->{weekdays_all}})
            && scalar keys %modified == 1
            && (exists $self->{modified}{day} && $self->{modified}{day} == 1
            && Day_of_Week($self->{datetime}->year, $self->{datetime}->month, $self->{datetime}->day)
             < DateTime->now(time_zone => $self->{Time_zone})->wday)
        ) {
            $self->{postprocess}{day} = 7;
        }
        elsif ((any { my $month = $_; any { $_ =~ /$month/i } @{$self->{tokens}} } @{$self->{data}->{months_all}})
            && (all { /^(?:day|month)$/ } keys %modified)
            && (exists $self->{modified}{month} && $self->{modified}{month} == 1)
            && (exists $self->{modified}{day}
                  ? $self->{modified}{day} == 1
                    ? 1 : 0
                  : 1)
            && ($self->{datetime}->day_of_year < DateTime->now->day_of_year)
        ) {
            $self->{postprocess}{year} = 1;
        }
    }
}

sub _token
{
    my ($self, $pos) = @_;

    my $str = '';
    my $token = $self->{tokens}->[0 + $pos];

    return defined $token
      ? \$token
      : \$str;
}

sub _add_trace       { push @{$_[0]->{trace}}, (caller(1))[3] }
sub _unset_trace     { @{$_[0]->{trace}} = ()                 }

sub _get_error       { $_[0]->{error}         }
sub _set_error       { $_[0]->{error} = $_[1] }
sub _unset_error     { $_[0]->{error} = ''    }

sub _get_failure     { $_[0]->{failure}     }
sub _set_failure     { $_[0]->{failure} = 1 }
sub _unset_failure   { $_[0]->{failure} = 0 }

sub _get_valid_exp   { $_[0]->{valid_expression}     }
sub _set_valid_exp   { $_[0]->{valid_expression} = 1 }
sub _unset_valid_exp { $_[0]->{valid_expression} = 0 }

sub _get_modified    { $_[0]->{modified}{total} || 0     }
sub _set_modified    { $_[0]->{modified}{total} += $_[1] }
sub _unset_modified  { $_[0]->{modified}{total}  = 0     }

sub _get_datetime_object
{
    my $self = shift;

    $self->{Time_zone} = $self->{datetime}->time_zone->name;
    $self->{year}      = $self->{datetime}->year;
    $self->{month}     = $self->{datetime}->month;
    $self->{day}       = $self->{datetime}->day_of_month;
    $self->{hour}      = $self->{datetime}->hour;
    $self->{min}       = $self->{datetime}->minute;
    $self->{sec}       = $self->{datetime}->second;

    $self->{sec}       = sprintf("%02d", $self->{sec});
    $self->{min}       = sprintf("%02d", $self->{min});
    $self->{hour}      = sprintf("%02d", $self->{hour});
    $self->{day}       = sprintf("%02d", $self->{day});
    $self->{month}     = sprintf("%02d", $self->{month});

    my $dt = DateTime->new(time_zone => $self->{Time_zone},
                           year      => $self->{year},
                           month     => $self->{month},
                           day       => $self->{day},
                           hour      => $self->{hour},
                           minute    => $self->{min},
                           second    => $self->{sec});

    foreach my $unit (keys %{$self->{postprocess}}) {
        $dt->add("${unit}s" => $self->{postprocess}{$unit});
    }

    return $dt;
}

# solely for testing purpose
sub _set_datetime
{
    my ($self, $year, $month, $day, $hour, $min, $sec, $tz) = @_;

    $self->{datetime} = DateTime->new(time_zone => $tz || 'floating',
                                      year      => $year,
                                      month     => $month,
                                      day       => $day,
                                      hour      => $hour,
                                      minute    => $min,
                                      second    => $sec);
    $self->{running_tests} = 1;
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
     printf("%02d.%02d.%4d %02d:%02d:%02d\n", $dt->day,
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

=head1 CONSTRUCTOR

=head2 new

Creates a new C<DateTime::Format::Natural> object. Arguments to C<new()> are options and
not necessarily required.

 $parser = DateTime::Format::Natural->new(
           lang          => 'en',
           format        => 'mm/dd/yy',
           prefer_future => '[0|1]'
           time_zone     => 'floating',
           daytime       => { morning   => 06,
                              afternoon => 13,
                              evening   => 20,
                            },
 );

=over 4

=item * C<lang>

Contains the language selected, currently limited to C<en> (english).
Defaults to 'C<en>'.

=item * C<format>

Specifies the format of numeric dates, defaults to 'C<d/m/y>'.

=item * C<prefer_future>

Turns ambigious weekdays/months to their futuristic relatives. Accepts a boolean,
defaults to 0.

=item * C<time_zone>

The time zone to use when parsing and for output. Accepts any time zone
recognized by L<DateTime>. Defaults to 'floating'.

=item * C<daytime>

A hash consisting of specific hours given for peculiar daytimes. Daytimes may be
selectively changed.

=back

=head1 METHODS

=head2 parse_datetime

Creates a C<DateTime> object from a human readable date/time string.

 $dt = $parser->parse_datetime($date_string);
 $dt = $parser->parse_datetime(string => $date_string);

=over 4

=item * C<string>

The date string.

=back

Returns a L<DateTime> object.

=head2 parse_datetime_duration

Creates one or more C<DateTime> object(s) from a human readable date/time string
which may contain timespans/durations. 'Same' interface & options as C<parse_datetime()>,
but must be explicitly called in list context.

 @dt = $parser->parse_datetime_duration($date_string);
 @dt = $parser->parse_datetime_duration(string => $date_string);

=head2 success

Returns a boolean indicating success or failure for parsing the date/time
string given.

=head2 error

Returns the error message if the parsing didn't succeed.

=head2 trace

Returns a trace of methods which we're called within the Base class and
a summary how often certain units were modified.

=head1 GRAMMAR

The grammar handling has been rewritten to be easily extendable and hence 
everybody is encouraged to propose sensible new additions and/or changes.

See the classes C<DateTime::Format::Natural::Lang::[language_code]> if
you're intending to hack a bit on the grammar guts.

=head1 EXAMPLES

See the classes C<DateTime::Format::Natural::Lang::[language_code]> for a 
overview of current valid input.

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
 Shawn M. Moore
 Andreas J. König
 Chia-liang Kao
 Jonny Schulz
 Jesse Vincent
 Jason May
 Pat Kale

=head1 SEE ALSO

L<DateTime>, L<Date::Calc>, L<http://datetime.perl.org>

=head1 AUTHOR

Steven Schubiger <schubiger@cpan.org>

=head1 LICENSE

This program is free software; you may redistribute it and/or
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
