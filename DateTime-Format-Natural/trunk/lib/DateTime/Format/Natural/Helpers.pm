package DateTime::Format::Natural::Helpers;

use strict;
use warnings;
use base qw(Exporter);
use boolean qw(true false);

use constant REAL_FLAG => true;
use constant VIRT_FLAG => false;

our ($VERSION, @EXPORT_OK, %flag);

$VERSION = '0.02';

my @flags = (
    { weekday_name      => REAL_FLAG },
    { weekday_num       => REAL_FLAG },
    { month_name        => REAL_FLAG },
    { month_num         => REAL_FLAG },
    { last_this_next    => VIRT_FLAG },
    { yes_today_tom     => VIRT_FLAG },
    { noon_midnight     => VIRT_FLAG },
    { morn_aftern_even  => VIRT_FLAG },
    { before_after_from => VIRT_FLAG },
);

{
    my $i;
    %flag = map { (keys %$_)[0] => $i++ } @flags;
}

@EXPORT_OK = qw(%flag);

sub _helper
{
    my $self = shift;
    my ($flags, $string) = @_;

    foreach my $flag (@$flags) {
        my $name = (keys %{$flags[$flag]})[0];
        if ($flags[$flag]->{$name}) {
            my $meth = '_' . $name;
            $self->$meth(\$string);
        }
        else {
            $string = $self->{data}->{conversion}->{$name}->{lc $string};
        }
    }

    return $string;
}

sub _weekday_name
{
    my $self = shift;
    my ($arg) = @_;

    my $helper = $self->{data}->{helpers};

    if ($$arg =~ $helper->{suffix}) {
        $$arg =~ s/$helper->{suffix}//;
    }
    $helper->{normalize}->($arg);
    if ($helper->{abbreviated}->($arg)) {
        $$arg = $self->{data}->{weekdays_abbrev}->{$$arg};
    }
}

sub _weekday_num
{
    my $self = shift;
    my ($arg) = @_;

    $$arg = $self->_Decode_Day_of_Week($$arg);
}

sub _month_name
{
    my $self = shift;
    my ($arg) = @_;

    my $helper = $self->{data}->{helpers};

    $helper->{normalize}->($arg);
    if ($helper->{abbreviated}->($arg)) {
        $$arg = $self->{data}->{months_abbrev}->{$$arg};
    }
}

sub _month_num
{
    my $self = shift;
    my ($arg) = @_;

    $$arg = $self->_Decode_Month($$arg);
}

sub _add
{
    my $self = shift;
    my ($unit, $value) = @_;

    $unit .= 's' unless $unit =~ /s$/;
    $self->{datetime}->add($unit => $value);

    chop $unit;
    $self->{modified}{$unit}++;
}

sub _subtract
{
    my $self = shift;
    my ($unit, $value) = @_;

    $unit .= 's' unless $unit =~ /s$/;
    $self->{datetime}->subtract($unit => $value);

    chop $unit;
    $self->{modified}{$unit}++;
}

sub _add_or_subtract
{
    my $self = shift;

    if (ref $_[0] eq 'HASH') {
        my %opts = %{$_[0]};
        if ($opts{when} > 0) {
            $self->_add($opts{unit} => $opts{value});
        }
        elsif ($opts{when} < 0) {
            $self->_subtract($opts{unit} => $opts{value});
        }
    }
    elsif (scalar @_ == 2) {
        $self->_add(@_);
    }
}

sub _set
{
    my $self = shift;
    my %values = @_;

    $self->{datetime}->set(%values);

    foreach my $unit (keys %values) {
        $self->{modified}{$unit}++;
    }
}

sub _valid_date
{
    my $self = shift;
    my %values = @_;

    my %set = map { $_ => $self->{datetime}->$_ } qw(year month day);

    while (my ($unit, $value) = each %values) {
        $set{$unit} = $value;
    }

    if ($self->_check_date($set{year}, $set{month}, $set{day})) {
        return true;
    }
    else {
        $self->_set_failure;
        $self->_set_error("(date is not valid)");
        return false;
    }
}

sub _valid_time
{
    my $self = shift;
    my %values = @_;

    my %abbrev = (
        second => 'sec',
        minute => 'min',
        hour   => 'hour',
    );
    my %set = map { $_ => $self->{datetime}->$_ } values %abbrev;

    while (my ($unit, $value) = each %values) {
        $set{$abbrev{$unit}} = $value;
    }

    if ($self->_check_time($set{hour}, $set{min}, $set{sec})) {
        return true;
    }
    else {
        $self->_set_failure;
        $self->_set_error("(time is not valid)");
        return false;
    }
}

1;
__END__

=head1 NAME

DateTime::Format::Natural::Helpers - Various helper methods

=head1 SYNOPSIS

 Please see the DateTime::Format::Natural documentation.

=head1 DESCRIPTION

The C<DateTime::Format::Natural::Helpers> class defines helper methods.

=head1 SEE ALSO

L<DateTime::Format::Natural>

=head1 AUTHOR

Steven Schubiger <schubiger@cpan.org>

=head1 LICENSE

This program is free software; you may redistribute it and/or
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
