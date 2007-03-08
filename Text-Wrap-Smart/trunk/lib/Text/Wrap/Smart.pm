package Text::Wrap::Smart;

use strict;
use warnings;
use base qw(Exporter);

use Carp qw(croak);
use Math::BigFloat;

our ($VERSION, @EXPORT_OK);

$VERSION = '0.4';
@EXPORT_OK = qw(wrap_smart);

sub wrap_smart {
    my ($text, $conf) = @_;
    croak "wrap_smart(\\\$text [, { options } ])\n" unless $text;

    my $msg_size = $conf->{max_msg_size} || 160;
    my $no_split = $conf->{no_split};

    my ($i, $pos, @strings);

    my $length      = length $text;
    my $length_eval = $length;

    # Count possible chunks
    do {
        $length_eval -= $msg_size;
        $i++;
    } while ($length_eval > 0);

    # Ceil average message length
    my $x       = Math::BigFloat->new($length / $i);
    my $average = $x->bceil();

    if (!$no_split) {
        # Split text in *exact* substrings
        for ($pos = 0; $pos < $length; $pos += $average) {
            my $string = substr($text, $pos, $average);
            push @strings, $string;
        }
    } else {
        my ($have_space, $pos);

        my $offset    = 0;
        my $text_eval = $text;

        # Iterate while end position is not reached
        while ($offset < length($text) - 1) {
            # Determine nearest offset of a word boundary
            if (length $text_eval > $average && $text_eval =~ / /) {
                $pos        = rindex($text_eval, ' ', $average);
                $have_space = 1;
            # If space encountered & remaining text is less than average, 
            # set position to end; otherwise set position to msg size provided.
            } else {
                $pos = $have_space ? length $text_eval : $msg_size;
            }

            # Set position to remaining length if no word boundary is found
            $pos       = length $text_eval if $pos == -1;

            # Extract substring
            my $substr = substr($text_eval, 0, $pos);

            # Increment position to skip word boundary
            $pos++;
            my $length = 0;

            # Set position to end of index if end is reached
            if ($pos > length $text_eval) {
                $pos    = length $text_eval;
                $length = 0;
            # Otherwise, calculate remaining length of text
            } else {
                $length = length($text_eval) - $pos;
            }

            # Shrink the text accordingly & increment offset
            $text_eval = substr($text_eval, $pos, $length);
            $offset   += $pos;

            # Mark trailing spaces to be removed
            $/ = ' ';

            # Remove newline & push substring
            chomp $substr;
            push @strings, $substr;
       }
    }

    return @strings;
}

1;
__END__

=head1 NAME

Text::Wrap::Smart - Wrap text into chunks of equal length

=head1 SYNOPSIS

 use Text::Wrap::Smart qw(wrap_smart);

 $text = .. # random content & length
 
 %options = (
             no_split => 1,
             max_msg_size => 160,
            );

 @chunks = wrap_smart($text, \%options);

=head1 DESCRIPTION

C<Text::Wrap::Smart> was primarly developed to split an overly
long SMS message into chunks of equal size. The distribution's
C<wrap_smart()> may nevertheless be used for other purposes.

=head1 FUNCTIONS

=head2 wrap_smart

 @chunks = wrap_smart($text, \%options);

C<%options> may contain the C<no_split> option indicating that
words shall not be broken up. C<max_msg_size> sets the character
length boundary for each chunk emitted.

=head1 SEE ALSO

L<Text::Wrap>

=head1 AUTHOR

Steven Schubiger <schubiger@cpan.org>

=head1 LICENSE

This program is free software; you may redistribute it and/or 
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
