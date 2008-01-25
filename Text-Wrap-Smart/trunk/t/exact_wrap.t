#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 4;
use Text::Wrap::Smart qw(wrap_smart);

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

    my $text         = $args->[0];
    my $expected     = $args->[1];
    my $count        = $args->[2];
    my $max_msg_size = $args->[3];

    my %opts;
    $opts{max_msg_size} = $max_msg_size
      if $max_msg_size > 0;

    my @strings = wrap_smart($text, \%opts);

    my $msg_size = $opts{max_msg_size} ? $opts{max_msg_size} : 'default';
    my $msg_size_text = "(msg size: $msg_size)";

    my @msg = (
        "$msg_size_text correct amount of substrings",
        "$msg_size_text splitted at word boundary",
    );

    is(scalar @strings, $count, $msg[0]);
    is_deeply(\@strings, \@$expected, $msg[1]);
}
