package DateTime::Format::Natural::Duration;

use strict;
use warnings;

our $VERSION = '0.02';

sub _pre_duration
{
    my $self = shift;
    my ($date_strings) = @_;

    my $duration = $self->{data}->{duration};

    if ($duration->{for}->($date_strings)) {
        $self->{insert} = $self->parse_datetime('now');
    }
    elsif ($duration->{first_last}->($date_strings)) {
        if (my ($complete) = $date_strings->[1] =~ /^\S+? \s+ (.*)/x) {
            $date_strings->[0] .= " $complete";
        }
    }
}

sub _post_duration
{
    my $self = shift;
    my ($queue) = @_;

    if (exists $self->{insert}) {
        unshift @$queue, $self->{insert};
    }
}

sub _save_state
{
    my $self = shift;
    my %args = @_;

    return if scalar keys %{$self->{state}};

    unless ($args{valid_expression}) {
        %{$self->{state}} = %args;
    }
}

sub _restore_state
{
    my $self = shift;

    my %state = %{$self->{state}};

    if (scalar keys %state) {
        $state{valid_expression}
          ? $self->_set_valid_exp
          : $self->_unset_valid_exp;

        $state{failure}
          ? $self->_set_failure
          : $self->_unset_failure;

        defined $state{error}
          ? $self->_set_error($state{error})
          : $self->_unset_error;
    }
}

1;
__END__

=head1 NAME

DateTime::Format::Natural::Duration - Duration hooks and state handling

=head1 SYNOPSIS

 Please see the DateTime::Format::Natural documentation.

=head1 DESCRIPTION

The C<DateTime::Format::Natural::Duration> class contains code to alter
tokens before parsing and to insert DateTime objects in the resulting
queue. Furthermore, there's code to save the state of the first failing
parse and restore it after the duration has been processed.

=head1 SEE ALSO

L<DateTime::Format::Natural>

=head1 AUTHOR

Steven Schubiger <schubiger@cpan.org>

=head1 LICENSE

This program is free software; you may redistribute it and/or
modify it under the same terms as Perl itself.

See L<http://dev.perl.org/licenses/>

=cut
