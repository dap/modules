#!/usr/bin/perl

use strict;
use warnings;

use File::Temp ':POSIX';
use Hook::Output::File;
use IO::Capture::Stderr;
use IO::Capture::Stdout;
use Test::More tests => 4;

my $stdout_tmpfile = tmpnam();
my $stderr_tmpfile = tmpnam();

my $hook = Hook::Output::File->redirect(
    stdout => $stdout_tmpfile,
    stderr => $stderr_tmpfile,
);
print STDOUT 'stdout (redirected)';
print STDERR 'stderr (redirected)';
undef $hook;

my $get_file_content = sub
{
    open(my $fh, '<', $_[0]) or die "Cannot open $_[0]: $!\n";
    return do { local $/; <$fh> };
};

is($get_file_content->($stdout_tmpfile), 'stdout (redirected)', 'stdout redirected');
is($get_file_content->($stderr_tmpfile), 'stderr (redirected)', 'stderr redirected');

unlink $stdout_tmpfile;
unlink $stderr_tmpfile;

my $capture = IO::Capture::Stdout->new;
$capture->start;
print STDOUT 'stdout (captured)';
$capture->stop;
my @stdout_lines = $capture->read;

$capture = IO::Capture::Stderr->new;
$capture->start;
print STDERR 'stderr (captured)';
$capture->stop;
my @stderr_lines = $capture->read;

is_deeply(\@stdout_lines, [ 'stdout (captured)' ], 'stdout captured');
is_deeply(\@stderr_lines, [ 'stderr (captured)' ], 'stderr captured');
