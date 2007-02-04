#!/usr/bin/perl

use strict;
use warnings;

use Text::Wrap::Smart qw(wrap_smart);

my $text = 'abcdefghijklmnopqrstuvwxyz ' x 15;

my %options = (
               max_msg_size => 160,
               no_split => 1,
              );

my @messages = wrap_smart($text, \%options);

for (my $i = 0; $i < @messages; $i++) {
    my $excerpt = substr($messages[$i], 0, 30);
    my $len     = length($messages[$i]);
    my $c       = sprintf("%02i", $i);
    print "$c: length: $len; excerpt: $excerpt\n";
}
