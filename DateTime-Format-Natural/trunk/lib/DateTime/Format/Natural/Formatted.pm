package DateTime::Format::Natural::Formatted;

use strict;
use warnings;
use boolean qw(true);

our $VERSION = '0.02';

sub _parse_formatted_ymd
{
    my $self = shift;
    my ($date_string, $count) = @_;

    my $date = $self->_split_formatted($date_string);

    my $separator = quotemeta((keys %$count)[0]);
    my @chunks = split /$separator/, $date;

    my $i = 0;
    my %length = map { length $_ => $i++ } @chunks;

    my $format = lc $self->{Format};

    if (exists $length{4}) {
        $format = join $separator,
          ($length{4} == 0
            ? qw(yyyy mm dd)
            : ($format =~ /^m/
                ? qw(mm dd yyyy)
                : qw(dd mm yyyy)
              )
          );
    }
    else {
        $separator = do { local $_ = $format;
                          tr/a-zA-Z//d;
                          tr/a-zA-Z//cs;
                          quotemeta; };
    }

    my @separated_order = split /$separator/, $format;

    my ($d, $m, $y) = do {
        my %f = map { substr($_, 0, 1) => true } @separated_order;
        ($f{d}, $f{m}, $f{y});
    };
    unless (@separated_order == 3 and ($d && $m && $y)) {
        $self->_set_failure;
        $self->_set_error("('format' parameter invalid)");
        return $self->_get_datetime_object;
    }

    my $separated_index = 0;
    my $separated_indices = { map { substr($_, 0, 1) => $separated_index++ } @separated_order };

    my @bits = split /$separator/, $date;

    my $century = $self->{datetime}
                ? int($self->{datetime}->year / 100)
                : substr((localtime)[5] + 1900, 0, 2);

    my ($day, $month, $year) = map $bits[$separated_indices->{$_}], qw(d m y);

    if (length $year == 2) { $year = "$century$year" };

    unless ($self->_check_date($year, $month, $day)) {
        $self->_set_failure;
        $self->_set_error("(invalid date)");
        return $self->_get_datetime_object;
    }

    $self->_set(
        year  => $year,
        month => $month,
        day   => $day,
    );
    $self->{datetime}->truncate(to => 'day');
    $self->_set_valid_exp;

    $self->_process_tokens;

    return undef;
}

sub _parse_formatted_md
{
    my $self = shift;
    my ($date_string) = @_;

    my $date = $self->_split_formatted($date_string);

    my ($month, $day) = split /\//, $date;

    unless ($self->_check_date($self->{datetime}->year, $month, $day)) {
        $self->_set_failure;
        $self->_set_error("(invalid date)");
        return $self->_get_datetime_object;
    }

    $self->_set(
        month => $month,
        day   => $day,
    );
    $self->{datetime}->truncate(to => 'day');
    $self->_set_valid_exp;

    $self->_process_tokens;

    return undef;
}

sub _split_formatted
{
    my $self = shift;
    my ($date_string) = @_;

    my $date;
    if ($date_string =~ /^\S+\b \s+ \b\S+/x) {
        ($date, @{$self->{tokens}}) = split /\s+/, $date_string;
        $self->{count}{tokens} = 1 + @{$self->{tokens}};
    }
    else {
        $self->{count}{tokens} = 1;
    }

    return defined $date ? $date : $date_string;
}

sub _process_tokens
{
    my $self = shift;

    if (@{$self->{tokens}}) {
        $self->{count}{tokens}--;
        $self->_unset_valid_exp;
        $self->_process;
    }
}

1;
__END__

=head1 NAME

DateTime::Format::Natural::Formatted - Processing of formatted dates

=head1 SYNOPSIS

 Please see the DateTime::Format::Natural documentation.

=head1 DESCRIPTION

The C<DateTime::Format::Natural::Formatted> class contains methods
to parse formatted dates.

=head1 SEE ALSO

L<DateTime::Format::Natural>

=head1 AUTHOR

Steven Schubiger <schubiger@cpan.org>

=head1 LICENSE

This program is free software; you may redistribute it and/or
modify it under the same terms as Perl itself.

See L<http://dev.perl.org/licenses/>

=cut
