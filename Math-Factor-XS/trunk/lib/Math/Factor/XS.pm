package Math::Factor::XS;

use strict;
use warnings;
use base qw(Exporter);
use boolean qw(true);

use Carp qw(croak);
use List::MoreUtils qw(all);
use Params::Validate ':all';
use Scalar::Util qw(looks_like_number);

our ($VERSION, @EXPORT_OK, %EXPORT_TAGS, @subs);

$VERSION = '0.36_01';
@subs = qw(factors matches);
@EXPORT_OK = @subs;
%EXPORT_TAGS = (all => [ @subs ]);

validation_options(
    on_fail => sub
{
    my ($error) = @_;
    chomp $error;
    croak $error;
});

my $is_positive_num = sub
{
    all { looks_like_number($_) && ($_ >= 0) }
      ref $_[0] ? @{$_[0]} : ($_[0]);
};

sub factors
{
    validate_pos(@_,
        { type => SCALAR,
          callbacks => {
            'is a positive number' =>
            $is_positive_num,
          },
        },
    );
    return xs_factors(@_);
}

sub matches
{
    validate_pos(@_,
        { type => SCALAR,
          callbacks => {
            'is a positive number' =>
            $is_positive_num,
          },
        },
        { type => ARRAYREF,
          callbacks => {
            'factors are positive numbers' =>
            $is_positive_num,
          },
        },
        { type => HASHREF,
          optional => true,
        },
    );
    return xs_matches(@_);
}

require XSLoader;
XSLoader::load(__PACKAGE__, $VERSION);

1;
__END__

=head1 NAME

Math::Factor::XS - Factorize numbers and calculate matching multiplications

=head1 SYNOPSIS

 use Math::Factor::XS ':all';
 # or
 use Math::Factor::XS qw(factors matches);

 $number = 30107;

 @factors = factors($number);
 @matches = matches($number, \@factors);

 print "$factors[1]\n";
 print "$number == $matches[0][0] * $matches[0][1]\n";

=head1 DESCRIPTION

C<Math::Factor::XS> factorizes numbers by applying trial divisions.

=head1 FUNCTIONS

=head2 factors

Factorizes numbers.

 @factors = factors($number);

The number will be entirely factorized and its factors will be returned
as a list.

=head2 matches

Calculates matching multiplications.

 @matches = matches($number, \@factors, { skip_multiples => [0|1] });

The factors will be multiplicated against each other and all combinations
that equal the number itself will be returned as a two-dimensional list.
The matches are accessible through the indexes; for example, the first
two numbers that matched the number may be accessed by C<$matches[0][0]>
and C<$matches[0][1]>, the second pair by C<$matches[1][0]> and
C<$matches[1][1]>, and so on.

The hashref provided at the end is optional. If C<skip_multiples>
is set to a true value, then matching multiplications that contain
multiplicated small factors will be discarded. Example:

 11 * 2737 == 30107 # accepted
 77 * 391  == 30107 # discarded

Direct use of C<$Math::Factor::XS::Skip_multiple> does no longer
have an effect as it has been superseded by C<skip_multiples>.

=head1 EXPORT

=head2 Functions

C<factors(), matches()> are exportable.

=head2 Tags

C<:all - *()>

=head1 AUTHOR

Steven Schubiger <schubiger@cpan.org>

=head1 LICENSE

This program is free software; you may redistribute it and/or
modify it under the same terms as Perl itself.

See L<http://dev.perl.org/licenses/>

=cut
