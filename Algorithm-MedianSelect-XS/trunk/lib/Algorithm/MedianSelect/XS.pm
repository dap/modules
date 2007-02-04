package Algorithm::MedianSelect::XS;

use strict;
use warnings;
use base qw(Exporter);

use Carp qw(carp);

our ($VERSION, @EXPORT_OK);

$VERSION = '0.18';
@EXPORT_OK = qw(median);

require XSLoader;
XSLoader::load(__PACKAGE__, $VERSION);

sub median {
    my $opts = pop if ref $_[-1] eq 'HASH';
    my @nums = @_;

    my $i;
    my %valid_alg = map { $_ => ++$i } qw(bubble quick);

    my $algorithm;

    if ($opts->{algorithm} && $valid_alg{$opts->{algorithm}}) {
        $algorithm = $opts->{algorithm};
    } else {
        carp "$opts->{algorithm} is no valid algorithm, switching to default...\n"
          if defined $opts->{algorithm} && !exists $opts->{algorithm};

        $algorithm ||= 'quick';
    }

    no strict 'refs';
    ${__PACKAGE__.'::ALGORITHM'} = $valid_alg{$algorithm};

    if (ref $nums[0] eq 'ARRAY') { return xs_median($nums[0]) }
    else                         { return xs_median(@nums)    }
}

1;
__END__

=head1 NAME

Algorithm::MedianSelect::XS - Median finding algorithm

=head1 SYNOPSIS

 use Algorithm::MedianSelect::XS qw(median);

 my @numbers = (1,2,3,5,6,7,9,12,14,19,21);

 print median(@numbers);
 print median(\@numbers);

 print median(\@numbers, { algorithm => 'bubble' }); # slow algorithm
 print median(\@numbers, { algorithm => 'quick'  }); # default algorithm

=head1 DESCRIPTION

Algorithm::MedianSelect::XS finds the item which is smaller
than half of the integers and bigger than half of the integers.

=head1 FUNCTIONS

=head2 median

Takes a list or reference to list of integers and returns the median number.
Optionally, the algorithm being used for computation may be specified within
a hash reference. See SYNOPSIS for algorithms currently available.

=head1 EXPORT

C<median()> is exportable.

=head1 SEE ALSO

L<http://www.cs.sunysb.edu/~algorith/files/median.shtml>

=head1 AUTHOR

Steven Schubiger <schubiger@cpan.org>

=head1 LICENSE

This program is free software; you may redistribute it and/or
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut

