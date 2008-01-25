package Text::Wrap::Smart;

use strict;
use warnings;
use base qw(Exporter);

use Carp qw(croak);
use Math::BigFloat;

our ($VERSION, @EXPORT_OK);

$VERSION = '0.6';
@EXPORT_OK = qw(wrap_smart);

sub wrap_smart
{
    my ($text, $conf) = @_;
    croak "wrap_smart(\\\$text [, { options } ])\n" unless defined $text;

    my $msg_size = $conf->{max_msg_size} || 160;
    my $no_split = $conf->{no_split};

    my $exact_split = !$no_split;

    my $i;
    my $length = length $text;
    my $length_eval = $length;

    do {
        $length_eval -= $msg_size;
        $i++;
    } while ($length_eval > 0);

    my $x = Math::BigFloat->new($length / $i);
    my $average = $x->bceil;

    if ($exact_split) {
        return _exact_wrap($text, $conf, $average)
    }
    else {
        return _fuzzy_wrap($text, $conf, $average);
    }
}

sub _exact_wrap
{
    my ($text, $conf, $average) = @_;

    my (@chunks, $pos);
    my $length = length $text;

    for ($pos = 0; $pos < $length; $pos += $average) {
        my $chunk = substr($text, $pos, $average);
        push @chunks, $chunk;
    }

    return @chunks;
}

sub _fuzzy_wrap
{
    my ($text, $conf, $average) = @_;

    my (@chunks, $have_space, $pos);
    my $msg_size = $conf->{max_msg_size} || 160;

    my $offset = 0;
    my $text_eval = $text;

    while ($offset < length($text) - 1) {
        if (length $text_eval > $average && $text_eval =~ / /) {
            $pos = rindex($text_eval, ' ', $average);
            $have_space = 1;
        }
        else {
            $pos = $have_space ? length $text_eval : $msg_size;
        }

        $pos = length $text_eval if $pos == -1;
        my $chunk = substr($text_eval, 0, $pos);
        $pos++;
        my $length = 0;

        if ($pos > length $text_eval) {
            $pos = length $text_eval;
            $length = 0;
        }
        else {
            $length = length($text_eval) - $pos;
        }

        $text_eval = substr($text_eval, $pos, $length);
        $offset += $pos;

        local $/ = ' ';
        chomp $chunk;

        push @chunks, $chunk;
    }

    return @chunks;
}

1;
__END__

=head1 NAME

Text::Wrap::Smart - Wrap text into chunks of (mostly) equal length

=head1 SYNOPSIS

 use Text::Wrap::Smart qw(wrap_smart);

 $text = "..."; # random length

 # example options
 %options = (
             no_split => 1,
             max_msg_size => 160,
            );

 @chunks = wrap_smart($text, \%options);

=head1 DESCRIPTION

C<Text::Wrap::Smart> was primarly developed to split an overly long SMS
message into chunks of mostly equal size. The distribution's C<wrap_smart()>
may nevertheless be suitable for other purposes.

=head1 FUNCTIONS

=head2 wrap_smart

 @chunks = wrap_smart($text [, { options } ]);

C<options> may contain the C<no_split> option indicating that words
shall not be broken up which indicates 'fuzzy wrapping` (if C<no_split> is
undefined, 'exact wrapping` will be applied). C<max_msg_size> sets the
character length boundary for each chunk emitted.

=head1 SEE ALSO

L<Text::Wrap>

=head1 AUTHOR

Steven Schubiger <schubiger@cpan.org>

=head1 LICENSE

This program is free software; you may redistribute it and/or
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
