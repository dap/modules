#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 4;
use Text::Wrap::Smart::XS qw(exact_wrap);

my @expected = (
    [
      'abcdefghijklmnopqrstuvwxyz ' x 5,
      'abcdefghijklmnopqrstuvwxyz ' x 5, ],
    [ 'abcdefghijklmnopqrstuvwxyz abc',
      'defghijklmnopqrstuvwxyz abcdef',
      'ghijklmnopqrstuvwxyz abcdefghi',
      'jklmnopqrstuvwxyz abcdefghijkl',
      'mnopqrstuvwxyz abcdefghijklmno',
      'pqrstuvwxyz abcdefghijklmnopqr',
      'stuvwxyz abcdefghijklmnopqrstu',
      'vwxyz abcdefghijklmnopqrstuvwx',
      'yz abcdefghijklmnopqrstuvwxyz ',  ],
);

# Contains four fields: text to be wrapped, expected result,
# amount of substrings expected and the maximum size of a chunk.
my @args = (
    [ 'abcdefghijklmnopqrstuvwxyz ' x 10, $expected[0], 2,  0 ],
    [ 'abcdefghijklmnopqrstuvwxyz ' x 10, $expected[1], 9, 30 ],
);

foreach my $args (@args) {
    test_wrap($args);
}

sub test_wrap
{
    my ($args) = @_;

    my $text     = $args->[0];
    my $expected = $args->[1];
    my $count    = $args->[2];
    my $wrap_at  = $args->[3];

    my @strings = exact_wrap($text, $wrap_at);

    my $wrapping_length = $wrap_at ? $wrap_at : 'default';
    my $wrapping_length_text = "(wrapping length: $wrapping_length)";

    my @msg = (
        "$wrapping_length_text correct amount of substrings",
        "$wrapping_length_text splitted at word boundary",
    );

    is(scalar @strings, $count, $msg[0]);
    is_deeply(\@strings, \@$expected, $msg[1]);
}
