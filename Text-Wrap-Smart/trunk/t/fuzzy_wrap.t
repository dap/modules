#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 14;
use Text::Wrap::Smart qw(wrap_smart);

# Expected substrings to be returned by wrap_smart()
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

    my $text         = $args->[0];
    my $expected     = $args->[1];
    my $count        = $args->[2];
    my $max_msg_size = $args->[3];

    my %opts = (no_split => 1);

    $opts{max_msg_size} = $max_msg_size
      if $max_msg_size > 0;

    my @strings = wrap_smart($text, \%opts);

    local $/ = ' ';
    chomp @$expected;

    my $msg_size = $opts{max_msg_size} ? $opts{max_msg_size} : 'default';
    my $msg_size_text = "(msg size: $msg_size)";

    my @msg = (
        "$msg_size_text correct amount of substrings",
        "$msg_size_text splitted at word boundary",
    );

    is(scalar @strings, $count, $msg[0]);
    is_deeply(\@strings, \@$expected, $msg[1]);
}
