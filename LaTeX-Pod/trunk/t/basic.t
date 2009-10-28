#!/usr/bin/perl

use strict;
use warnings;

use File::Spec;
use FindBin qw($Bin);
use LaTeX::Pod;
use Test::More tests => 1;

my $parser = LaTeX::Pod->new(File::Spec->catfile($Bin, 'data', 'basic.t.in'));
$parser->convert;

my $got = $parser->_pod_get;
my @expected = split /\n/, do { local $/; <DATA> };
$expected[-1] .= "\n";

is_deeply(\@$got, \@expected);

__DATA__
=head1 1
=over 4
=item 1
abc
=back
=head2 1
def
=head2 2
=over 4
=item 2
 ghi
=back
=head3 1
=over 4
=item 3
jkl
=back
=head3 2
mno
=head1 2
 pqr
=head2 1
stu
=head1 3
vwx
=cut
