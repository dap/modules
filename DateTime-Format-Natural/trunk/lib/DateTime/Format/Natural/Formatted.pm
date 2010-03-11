package DateTime::Format::Natural::Formatted;

use strict;
use warnings;
use boolean qw(true false);

our $VERSION = '0.04';

sub _parse_formatted_ymd
{
    my $self = shift;
    my ($date_string, $count) = @_;

    my $date = $self->_split_formatted($date_string);

    my $date_sep = quotemeta((keys %$count)[0]);
    my @chunks = split /$date_sep/, $date;

    my $i = 0;
    my %length = map { length $_ => $i++ } @chunks;

    my $format = lc $self->{Format};
    my $format_sep;

    my $lax = false;

    if (exists $length{4}) {
        $format = join $date_sep,
          ($length{4} == 0
            ? qw(yyyy mm dd)
            : ($format =~ /^m/
                ? qw(mm dd yyyy)
                : qw(dd mm yyyy)
              )
          );
        $lax = true;
    }
    elsif ($date_sep =~ /^\\[-.]$/ and $format !~ /$date_sep/) {
        $format = join $date_sep, qw(dd mm yy);
        $lax = true;
    }
    else {
        $format_sep = do { local $_ = $format;
                           tr/a-zA-Z//d;
                           tr/a-zA-Z//cs;
                           quotemeta; };
    }
    $format_sep ||= $date_sep;

    if (not $lax and ($format_sep ne $date_sep)) {
        $self->_set_failure;
        $self->_set_error("(mismatch between format and date separator)");
        return $self->_get_datetime_object;
    }

    my @separated_order = split /$format_sep/, $format;

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

    my @bits = split /$date_sep/, $date;

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
