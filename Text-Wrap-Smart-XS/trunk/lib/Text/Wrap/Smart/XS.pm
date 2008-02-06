package Text::Wrap::Smart::XS;

use strict;
use warnings;
use base qw(Exporter);

use Carp qw(croak);

our ($VERSION, @EXPORT_OK, %EXPORT_TAGS, @subs);

$VERSION = '0.02';
@subs = qw(exact_wrap fuzzy_wrap);
@EXPORT_OK = @subs;
%EXPORT_TAGS = ('all' => [ @subs ]);

use constant WRAP_AT_DEFAULT => 160;

sub exact_wrap
{
    my ($text, $wrap_at) = @_;
    croak "exact_wrap(\\\$text [, \$wrap_at ])\n" unless defined $text;

    $wrap_at ||= WRAP_AT_DEFAULT;

    return xs_exact_wrap($text, $wrap_at);
}

sub fuzzy_wrap
{
    my ($text, $wrap_at) = @_;
    croak "fuzzy_wrap(\\\$text [, \$wrap_at ])\n" unless defined $text;

    $wrap_at ||= WRAP_AT_DEFAULT;

    return xs_fuzzy_wrap($text, $wrap_at);
}

require XSLoader;
XSLoader::load(__PACKAGE__, $VERSION);

1;
__END__

=head1 NAME

Text::Wrap::Smart::XS - Wrap text fast into chunks of (mostly) equal length

=head1 SYNOPSIS

 use Text::Wrap::Smart::XS ':all';
 # or
 use Text::Wrap::Smart::XS qw(exact_wrap fuzzy_wrap);

 @chunks = exact_wrap($text, $wrap_at);
 @chunks = fuzzy_wrap($text, $wrap_at);

=head1 DESCRIPTION

C<Text::Wrap::Smart::XS> is the faster companion of C<Text::Wrap::Smart>.

=head1 FUNCTIONS

=head2 exact_wrap

 @chunks = exact_wrap($text [, $wrap_at ]);

Wrap a text of varying length into exact chunks (except the last one,
which consists of the remaining text). Optionally a wrapping length
may be specified; if no length is supplied, a default of 160 will be
assumed.

=head2 fuzzy_wrap

 @chunks = fuzzy_wrap($text [, $wrap_at ]);

Wrap a text of varying length into chunks of fuzzy length (the boundary
is calculated from the last whitespace preceeding the wrapping length,
and if no remaining whitespace could be find, the end-of-text. Optionally
a wrapping length may be specified; if no length is supplied, a
default of 160 will be assumed.

=head1 EXPORT

=head2 Functions

C<exact_wrap(), fuzzy_wrap()> are exportable.

=head2 Tags

C<:all - *()>

=head1 SEE ALSO

L<Text::Wrap>, L<Text::Wrap::Smart>

=head1 AUTHOR

Steven Schubiger <schubiger@cpan.org>

=head1 LICENSE

This program is free software; you may redistribute it and/or
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
