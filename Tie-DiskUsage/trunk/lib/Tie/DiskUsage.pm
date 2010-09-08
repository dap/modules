package Tie::DiskUsage;

use strict;
use warnings;

use Carp qw(croak);
use Symbol ();
use Tie::Hash ();

our ($VERSION, @ISA, $DU_BIN);

$VERSION = '0.21';
@ISA = qw(Tie::StdHash);

$DU_BIN = '/usr/bin/du';

sub TIEHASH
{
    my $class = shift;
    return bless _tie(@_), $class;
}
sub UNTIE {}

sub _tie
{
    my $du = _locate_du();
    my $path = shift @_;
    my @opts = @_;

    _validate($path, \@opts);

    return _parse_usage($du, $path, @opts);
}

sub _validate
{
    my ($path, $opts) = @_;

    @$opts = map { (defined && length) ? $_ : () } @$opts;

    my %errors = (
        not_exists => 'an existing path',
        not_option => 'options to be short or long',
    );
    my $error = sub { "tie() requires $_[0]" };

    my $valid_opt = qr{
        ^(?:
              -\w           (?:(?:   \ +?)\S+)? # short
           | --\w{2}[-\w]*? (?:(?:\=|\ +?)\S+)? # long
         )$
    }ix;

    croak $error->($errors{not_exists})
      if defined $path && !-e $path;

    croak $error->($errors{not_option})
      if @$opts && grep !/$valid_opt/, @$opts;
}

sub _locate_du
{
    if (!-e $DU_BIN) {
        my $du_which = do { require File::Which; File::Which::which('du') };
        croak "Cannot locate du: $!" unless defined $du_which;

        return $du_which;
    }
    else {
        croak "Cannot run `$DU_BIN': Not executable" unless -x $DU_BIN;

        return $DU_BIN;
    }
}

sub _parse_usage
{
    my ($du, $path, @opts) = @_;
    $path ||= do { require Cwd; Cwd::getcwd() };

    my $pipe = Symbol::gensym();
    open($pipe, "$du @opts $path |") or exit(1);

    my %usage;
    while (my $line = <$pipe>) {
        my ($size, $item) = $line =~ /^(.+?) \s+? (.+)$/x;
        $usage{$item} = $size;
    }

    close($pipe);

    return \%usage;
}

1;
__END__

=head1 NAME

Tie::DiskUsage - Tie disk usage to a hash

=head1 SYNOPSIS

 use Tie::DiskUsage;

 tie %usage, 'Tie::DiskUsage', '/var', '-h';
 print $usage{'/var/log'};
 untie %usage;

=head1 DESCRIPTION

C<Tie::DiskUsage> ties the disk usage, which is extracted from the output
of C<du(1)>, to a hash. If the path to perform the C<du> command on is C<undef>,
the current working directory will be examined; options to C<du> may be
passed at the end of the C<tie> invocation with a string provided per option.

By default, the location of the C<du> command is assumed to be at F</usr/bin/du>;
if C<du> cannot be found there, C<File::Which> will attempt to gather its real
location.

The default path to C<du> may be overridden by setting the global
C<$Tie::DiskUsage::DU_BIN> (usually not needed due to C<File::Which>'s
automatic search for C<du>).

=head1 BUGS & CAVEATS

Processing output of C<du(1)> requires that each output line is ended
by a newline.

=head1 SEE ALSO

L<perlfunc/tie>, du(1), L<Filesys::DiskUsage>, L<Sys::Statistics::Linux>

=head1 AUTHOR

Steven Schubiger <schubiger@cpan.org>

=head1 LICENSE

This program is free software; you may redistribute it and/or
modify it under the same terms as Perl itself.

See L<http://dev.perl.org/licenses/>

=cut
