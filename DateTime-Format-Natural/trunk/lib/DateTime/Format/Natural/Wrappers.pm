package DateTime::Format::Natural::Wrappers;

use strict;
use warnings;

our $VERSION = '0.01';

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
    elsif (@_ == 2) {
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

1;
__END__

=head1 NAME

DateTime::Format::Natural::Wrappers - Wrappers for DateTime operations

=head1 SYNOPSIS

 Please see the DateTime::Format::Natural documentation.

=head1 DESCRIPTION

The C<DateTime::Format::Natural::Wrappers> class provides internal wrappers
for DateTime operations.

=head1 SEE ALSO

L<DateTime::Format::Natural>

=head1 AUTHOR

Steven Schubiger <schubiger@cpan.org>

=head1 LICENSE

This program is free software; you may redistribute it and/or
modify it under the same terms as Perl itself.

See L<http://dev.perl.org/licenses/>

=cut
