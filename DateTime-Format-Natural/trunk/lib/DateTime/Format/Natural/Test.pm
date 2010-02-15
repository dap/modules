package DateTime::Format::Natural::Test;

use strict;
use warnings;
use base qw(Exporter);
use boolean qw(true);

use Test::More;

our ($VERSION, @EXPORT, %time, $case_strings);

$VERSION = '0.05';

@EXPORT = qw(%time $case_strings _run_tests _result_string _message);

%time = map { split /:/ }
        split /\n/,
        do { local $/ = '__END__';
             local $_ = <DATA>;
             chomp;
             $_ };

$case_strings = sub { ($_[0], lc $_[0], uc $_[0]) };

sub _run_tests
{
    my ($tests, $sets, $check) = @_;

    $tests *= 3; # case tests

    local $@;

    if (eval "require Date::Calc") {
        plan tests => $tests * 2;
        foreach my $set (@$sets) {
            $check->(@$set);
        }
    }
    else {
        plan tests => $tests;
    }

    $DateTime::Format::Natural::Compat::Pure = true;

    foreach my $set (@$sets) {
        $check->(@$set);
    }
}

sub _result_string
{
    my ($dt) = @_;

    my $string = sprintf(
        '%02d.%02d.%4d %02d:%02d:%02d',
        map $dt->$_, qw(day month year hour min sec)
    );

    return $string;
}

sub _message
{
    my ($msg) = @_;

    my $how = $DateTime::Format::Natural::Compat::Pure
      ? '(using DateTime)'
      : '(using Date::Calc)';

    return "$msg $how";
}

1;
__DATA__
year:2006
month:11
day:24
hour:1
minute:13
second:8

__END__

=head1 NAME

DateTime::Format::Natural::Test - Common test routines/data

=head1 SYNOPSIS

 Please see the DateTime::Format::Natural documentation.

=head1 DESCRIPTION

The C<DateTime::Format::Natural::Test> class exports common test routines.

=head1 SEE ALSO

L<DateTime::Format::Natural>

=head1 AUTHOR

Steven Schubiger <schubiger@cpan.org>

=head1 LICENSE

This program is free software; you may redistribute it and/or
modify it under the same terms as Perl itself.

See L<http://dev.perl.org/licenses/>

=cut
