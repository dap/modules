#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 14;
use Text::Wrap::Smart::XS qw(fuzzy_wrap);

my @expected = (
    [ ('abcdefghijklmnopqrstuvwxyz ' x 5) x 2          ],
    [  'a b c d e f g h i j', 'k l m n o a b c d e',
       'f g h i j k l m n o'                           ],
    [ ('ab cd ef gh ij kl mn op qr st') x 3            ],
    [  'abcdef ghijklnm opqrstuvwxyz abcdef ghijklnm',
       'opqrstuvwxyz abcdef ghijklnm opqrstuvwxyz'     ],
    [  'abcdefghijklmn opqrstuvwxyz abcdefghijklmn ' .
       'opqrstuvwxyz abcdefghijklmn',
       'opqrstuvwxyz abcdefghijklmn opqrstuvwxyz ' .
       'abcdefghijklmn opqrstuvwxyz',                  ],
    [ ('abcdefghijklmnopqrstuvwxyz ' .
       'abcdefghijklmnopqrstuvwxyz') x 4,              ],
    [  'abcdefghijklmnopqrstuvwxyz ' .
       'abcdefghijklmnopqrstuvwxyz'                    ],
);

# Contains four fields: text to be wrapped, expected result,
# amount of substrings expected and the maximum size of a chunk.
my @args = (
    [ 'abcdefghijklmnopqrstuvwxyz '    x 10, $expected[0], 2,   0 ],
    [ 'a b c d e f g h i j k l m n o ' x  2, $expected[1], 3,  20 ],
    [ 'ab cd ef gh ij kl mn op qr st ' x  3, $expected[2], 3,  40 ],
    [ 'abcdef ghijklnm opqrstuvwxyz '  x  3, $expected[3], 2,  60 ],
    [ 'abcdefghijklmn opqrstuvwxyz '   x  5, $expected[4], 2,  75 ],
    [ 'abcdefghijklmnopqrstuvwxyz '    x  8, $expected[5], 4, 100 ],
    [ 'abcdefghijklmnopqrstuvwxyz '    x  2, $expected[6], 1, 200 ],
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

    my @strings = fuzzy_wrap($text, $wrap_at);

    local $/ = ' ';
    chomp @$expected;

    my $wrapping_length = $wrap_at ? $wrap_at : 'default';
    my $wrapping_length_text = "(wrapping length: $wrapping_length)";

    my @msg = (
        "$wrapping_length_text correct amount of substrings",
        "$wrapping_length_text splitted at word boundary",
    );

    is(scalar @strings, $count, $msg[0]);
    is_deeply(\@strings, \@$expected, $msg[1]);
}
