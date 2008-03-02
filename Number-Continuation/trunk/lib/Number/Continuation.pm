package Number::Continuation;

use strict;
use warnings;
use base qw(Exporter);

use Carp qw(croak);
use Scalar::Util qw(refaddr);

our ($VERSION, @EXPORT_OK);

$VERSION = '0.04';
@EXPORT_OK = qw(continuation);

sub continuation
{
    my $opts = pop if ref $_[-1] eq 'HASH';

    my $input = ref $_[0] eq 'ARRAY'
      ? join ' ', @{$_[0]}
      : @_ > 1
        ? join ' ', @_
        : !refaddr $_[0]
          ? $_[0]
          : croak 'continuation($set | @set | \@set [, { options } ])';

    _validate($input);

    my $wantarray = wantarray;

    $opts->{delimiter} ||= '';
    $opts->{range}     ||= '-';
    $opts->{separator} ||= ',';

    @{$opts->{delimiters}} = split //, $opts->{delimiter};

    my @nums = split /\s+/, $input;

    my (%constructed, $have_neg_continuation, @lists, $output, @output);

    my $reset = 1;

    for (my $i = 0; $i < @nums; $i++) {
        # handy variables
        my $prev_number    = $nums[$i-1] || 0;
        my $current_number = $nums[$i  ] || 0;
        my $next_number    = $nums[$i+1] || 0;

        # set if preceeded by continuation
        my $prev_continuation = 1 if $constructed{begin}
                                  && $constructed{middle}
                                  && $constructed{end};

        # set if negative continuation sensed (i.e. 3 2 1)
        $have_neg_continuation = 1 if ($prev_number - $next_number == 2);

        # previous number greater than current one
        if ($prev_number > $current_number && $i != 0 && !$have_neg_continuation) {
            # previous number *exactly* greater 1
            if ($prev_number - $current_number == 1) {
                if ($wantarray) {
                    if (@lists) {
                        push @output, [ @lists ];
                        undef @lists;
                    }
                } else {
                    $output .= "$opts->{separator} ";
                }
            # previous number greater than 1 and no previous continuation
            } else {
                if ($wantarray) {
                    if (@lists) {
                        push @output, [ @lists ];
                        undef @lists;
                    }
                } else {
                    $output .= "$opts->{separator} " unless $prev_continuation;
                }
            }
            # reset processing continuation state
            $reset = 1;
        }
        # processing new continuation
        if ($reset) {
            if ($wantarray) {
                push @lists, $nums[$i];
                push @output, [ @lists ] if $i == $#nums;
            } else {
                $output .= $opts->{delimiters}->[0] if $opts->{delimiters}->[0];
                $output .= $nums[$i];
            }
            if (($next_number - $current_number) > 1) {
                if ($wantarray) {
                    if (@lists) {
                        push @output, [ @lists ];
                        undef @lists;
                    }
                } else {
                    $output .= "$opts->{separator} ";
                }
                next;
            }
            ($have_neg_continuation, $reset) = (0,0);
            undef %constructed;

            $constructed{begin} = 1;
        # process numbers in between (skipping if scalar context)
        } elsif (defined($next_number) && (($next_number - $current_number) == 1
                                       ||  ($current_number - $next_number) == 1)) {
            if ($wantarray) {
                push @lists, $current_number;
            } else { # blissfully do nothing when scalar context
            }
            $constructed{middle} = 1;
        # end processing current continuation
        } else {
            if ($wantarray) {
                push @lists, $current_number;
                push @output, [ @lists ];
                undef @lists;
            } else {
                $output .= $opts->{range}.$current_number;
                $output .= $opts->{delimiters}->[-1] if $opts->{delimiters}->[-1];
                $output .= "$opts->{separator} "     unless $i == $#nums;
            }
            $reset = 1;
            $constructed{end} = 1;
        }
    }

    return wantarray ? @output : $output;
}

sub _validate
{
    my ($set) = @_;

    croak 'continuation(): empty set provided' unless defined $set;

    my $RE_valid = qr{(?:[\d\-]+\ ?)+};
    1 while $set =~ /\G$RE_valid/gc;
    unless ($set =~ /\G$/) {
        croak "continuation(): invalid set provided: '$set`";
    }
}

1;
__END__

=head1 NAME

Number::Continuation - Create number continuations

=head1 SYNOPSIS

 use Number::Continuation qw(continuation);

 $set = '1 2 3 6 7 10 11 12 14';
 @set = (1,2,3,6,7,10,11,12,14);

 $contin = continuation($set);
 @contin = continuation($set);

 $contin = continuation(@set);
 @contin = continuation(@set);

 $contin = continuation(\@set);
 @contin = continuation(\@set);

 $contin = continuation($set, { delimiter => '[]', range => '~', separator => ';' });
 ...

 __OUTPUT__

 scalar context ($contin): '1-3, 6-7, 10-12, 14';
 list   context (@contin): [1,2,3], [6,7], [10,11,12], [14];

=head1 DESCRIPTION

=head2 continuation

 continuation($set | @set | \@set [, { options } ])

Returns in scalar context a stringified representation of a number continuation.
In list context a two-dimensional array is returned where each member represents
a list of numbers that belong to a single continuation or which are not member
of a continuation at all.

Continuation ranges may be negative.

It takes optionally a hash reference as last argument containing the parameters
C<delimiter>,C<range> and C<separator>. C<delimiter> may contain two characters,
where first one is appended to the beginning of a continuation and the second one
to the end; C<range> may consist of a single character which is being inserted
between the beginning and end of a continuation; C<separator> may be set
to a single character which ends a continuation.

C<delimiter>, C<range> and C<separator> aren't mandatory parameters. If options
aren't defined, a reasonable default will be assumed.

=head1 EXPORT

C<continuation()> is exportable.

=head1 AUTHOR

Steven Schubiger <schubiger@cpan.org>

=head1 LICENSE

This program is free software; you may redistribute it and/or
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
