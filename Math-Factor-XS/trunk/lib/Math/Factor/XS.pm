package Math::Factor::XS;

use strict;
use warnings;
use base qw(Exporter);

our ($VERSION, @EXPORT_OK, %EXPORT_TAGS, $Skip_multiple, @subs);

$VERSION = '0.35';
@subs = qw(factors matches);
@EXPORT_OK = @subs;
%EXPORT_TAGS = ('all' => [ @subs ]);
$Skip_multiple = 0;

require XSLoader;
XSLoader::load(__PACKAGE__, $VERSION);

1;
__END__

=head1 NAME

Math::Factor::XS - Factorise numbers and calculate matching multiplications

=head1 SYNOPSIS

 use Math::Factor::XS ':all';
 # or
 use Math::Factor::XS qw(factors matches);

 $number = 30107;

 @factors = factors($number);
 @matches = matches($number, @factors);

 print "$factors[1]\n";
 print "$number == $matches[0][0] * $matches[0][1]\n";

=head1 DESCRIPTION

C<Math::Factor::XS> factorises numbers by applying modulo operator divisons.

=head1 FUNCTIONS

=head2 factors

Factorises numbers.

 @factors = factors($number);

The number will be entirely factorised and its factors will be returned as list.

=head2 matches

Evaluates matching multiplications.

 @matches = matches($number, @factors);

The factors will be multplicated against each other and results that equal the number
itself, will be returned as two-multidimensional list.
The matches are accessible through the indexes, for example, the first two numbers
that matched the number, may be accessed by C<$matches[0][0]> and C<$matches[0][1]>,
the second ones by C<$matches[1][0]> and C<$matches[1][1]>, and so on.

If C<$Math::Factor::XS::Skip_multiple> is set to a true value, matching multiplications
that contain multiplicated (small) factors will be discarded.

Example:

 # accepted
 30107 == 11 * 2737

 # discarded
 30107 == 77 * 391

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

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
