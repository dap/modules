package Hook::Output::File;

use strict;
use warnings;

use base qw(Tie::Handle);

use Carp qw(croak);
use File::Spec ();

our @ISA = qw(Tie::StdHandle);

our $VERSION = '0.02';

sub redirect {
    my ($class, %opts) = @_;

    croak <<'EOT'
Hook::Output::File->redirect(stdout => 'absolute_path1',
                             stderr => 'absolute_path2');
EOT
      unless defined($opts{stdout})
          && defined($opts{stderr})
          && File::Spec->file_name_is_absolute($opts{stdout})
          && File::Spec->file_name_is_absolute($opts{stderr});

    no strict 'refs';
    my $caller = caller();

    tie *{$caller.'::STDOUT'}, 'Hook::Output::File';
    tie *{$caller.'::STDERR'}, 'Hook::Output::File';

    open(STDOUT, '>>', $opts{stdout}) or croak "Can't redirect STDOUT: $!";
    open(STDERR, '>>', $opts{stderr}) or croak "Can't redirect STDERR: $!";

    select(STDERR); $| = 1;
    select(STDOUT); $| = 1;

    return bless {}, ref($class) || $class;
}

DESTROY {
    no strict 'refs';
    my $caller = caller();

    no warnings 'untie';
    untie *{$caller.'::STDOUT'};
    untie *{$caller.'::STDERR'};
}

1;
__END__

=head1 NAME

Hook::Output::File - Redirect STDOUT/STDERR to a file

=head1 SYNOPSIS

 use Hook::Output::File;

 {
     my $hookout = Hook::Output::File->redirect(stdout => '/home/sts/test1.out',
                                                stderr => '/home/sts/test2.out');
     logged();

     undef $hookout;                          # restore previous state of handles

     not_logged();
 }

 sub logged {
     print STDOUT "logged: stdout!\n";        # stdout is redirected to logfile
     print STDERR "logged: stderr!\n";        # stderr is redirected to logfile
 }

 sub not_logged {
     print STDOUT "not logged: stdout!\n";    # stdout goes to stdout (not logfile)
     print STDERR "not logged: stderr!\n";    # stderr goes to stderr (not logfile)
}

=head1 DESCRIPTION

C<Hook::Output::File> redirects STDOUT/STDERR to a file.

=head1 METHODS

=head2 redirect

Installs a scoped file-redirection hook for regular output (STDOUT & STDERR). Don't
intermix the file locations for STDOUT & STDERR output or you will receive unexpected
results. The filenames will be checked that they're absolute and if not, an exception
will be thrown (because otherwise, the open() call would fail silently). The hook may
be uninstalled either explicitly or implicitly; former action requires to undef the
hook output "variable" (actually, it's a blessed object), latter one will automatically
achieved when exiting the current scope.

 {
     my $hookout = Hook::Output::File->redirect(stdout => '/home/sts/test1.out',
                                                stderr => '/home/sts/test2.out');
     some_sub();

     undef $hookout;   # explicitly uninstall hook

     another_sub();

 }   # implicitly uninstalls hook

=head1 SEE ALSO

L<perltie>

=head1 AUTHOR

Steven Schubiger <schubiger@cpan.org>

=head1 LICENSE

This program is free software; you may redistribute it and/or
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
