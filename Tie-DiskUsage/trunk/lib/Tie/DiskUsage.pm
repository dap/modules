package Tie::DiskUsage;

use strict;
use warnings;

use Carp qw(croak);
use Symbol ();
use Tie::Hash ();

our ($VERSION, @ISA, $DU_BIN);

@ISA = qw(Tie::StdHash);
$VERSION = '0.20';

$DU_BIN = '/usr/bin/du';

sub TIEHASH
{
    my $class = shift;
    return bless &_tie, $class;
}

sub UNTIE {}

sub _tie
{
    _locate_du();
    return &_parse_usage;
}

sub _locate_du
{
    if (not -e $DU_BIN && -x _) {
        eval {
            require File::Basename;
            require File::Which
        };
        die $@ if $@;
        my $du_which = File::Which::which('du');
        defined $du_which
          ? $DU_BIN = $du_which
          : croak "Can't locate ", File::Basename::basename($DU_BIN), ": $!";
    }
}

sub _parse_usage
{
    my $path = shift || '.';
    my $pipe = Symbol::gensym();

    open($pipe, "$DU_BIN @_ $path |") or exit(1);

    my %usage;
    while (my $line = <$pipe>) {
        my ($size, $item) = $line =~ /^(.*?)\s+?(.*)$/;
        $usage{$item} = $size;
    }

    close($pipe);

    return \%usage;
}

1;
__END__

=head1 NAME

Tie::DiskUsage - Tie disk-usage to a hash

=head1 SYNOPSIS

 use Tie::DiskUsage;

 tie %usage, 'Tie::DiskUsage', '/var', '-h';
 print $usage{'/var/log'};
 untie %usage;

=head1 DESCRIPTION

C<Tie::DiskUsage> ties the disk-usage, which is gathered
from the output of C<du>, to a hash. If the path to perform
the C<du> command on is being omitted, the current working
directory will be examined; optional arguments to C<du> may be
passed subsequently.

By default, the location of the C<du> command is to be
assumed in F</usr/bin/du>; if C<du> cannot be found to exist
there, C<File::Which> will attempt to gather its former location.

The default path to C<du> may be overriden by setting C<$Tie::DiskUsage::$DU_BIN>.

=head1 SEE ALSO

L<perlfunc/tie>, du(1), L<Filesys::DiskUsage>, L<Sys::Statistics::Linux>

=head1 AUTHOR

Steven Schubiger <schubiger@cpan.org>

=head1 LICENSE

This program is free software; you may redistribute it and/or
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
