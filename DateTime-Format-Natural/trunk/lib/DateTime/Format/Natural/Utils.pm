package DateTime::Format::Natural::Utils;

use strict;
use warnings;
use boolean qw(true false);

our $VERSION = '0.01';

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

DateTime::Format::Natural::Utils - Handy utility methods

=head1 SYNOPSIS

 Please see the DateTime::Format::Natural documentation.

=head1 DESCRIPTION

The C<DateTime::Format::Natural::Utils> class consists of utility methods.

=head1 SEE ALSO

L<DateTime::Format::Natural>

=head1 AUTHOR

Steven Schubiger <schubiger@cpan.org>

=head1 LICENSE

This program is free software; you may redistribute it and/or
modify it under the same terms as Perl itself.

See L<http://dev.perl.org/licenses/>

=cut
