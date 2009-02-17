package Hook::Output::File;

use strict;
use warnings;
use base qw(Tie::Handle);

use Carp qw(croak);
use File::Spec ();

our ($VERSION, @ISA);

$VERSION = '0.05';
@ISA = qw(Tie::StdHandle);

sub redirect
{
    my ($class, %opts) = @_;

    croak <<'EOT'
Hook::Output::File->redirect(stdout => 'absolute_path1',
                             stderr => 'absolute_path2');
EOT
      unless defined $opts{stdout}
          && defined $opts{stderr}
          && File::Spec->file_name_is_absolute($opts{stdout})
          && File::Spec->file_name_is_absolute($opts{stderr});

    no strict 'refs';
    my $caller = caller;

    tie *{$caller.'::STDOUT'}, 'Hook::Output::File';
    tie *{$caller.'::STDERR'}, 'Hook::Output::File';

    open(STDOUT, '>>', $opts{stdout}) or croak "Cannot redirect STDOUT: $!";
    open(STDERR, '>>', $opts{stderr}) or croak "Cannot redirect STDERR: $!";

    select STDOUT; $| = 1;
    select STDERR; $| = 1;

    return bless {}, ref($class) || $class;
}

DESTROY
{
    no strict 'refs';
    my $caller = caller;

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
     my $hook = Hook::Output::File->redirect(
         stdout => '/tmp/1.out',
         stderr => '/tmp/2.out',
     );
     
     saved();
     
     undef $hook; # restore previous state of streams 
     
     not_saved();
 }

 sub saved {
     print STDOUT "..."; # STDOUT output is appended to file
     print STDERR "..."; # STDERR output is appended to file
 }

 sub not_saved {
     print STDOUT "..."; # STDOUT output goes to STDOUT (not to file)
     print STDERR "..."; # STDERR output goes to STDERR (not to file)
 }

=head1 DESCRIPTION

C<Hook::Output::File> redirects C<STDOUT/STDERR> to a file.

=head1 METHODS

=head2 redirect

Installs a file-redirection hook for regular output streams (i.e.,
C<STDOUT & STDERR>) with lexical scope. 

A word of caution: do not intermix the file paths for C<STDOUT/STDERR>
output or you will eventually receive unexpected results. The paths
will be checked that they are absolute and if not, an usage help will
be printed (because otherwise, the C<open()> call might silently fail
to satisfy expectations). 

The hook may be uninstalled either explicitly or implicitly; doing it
explicit requires to unset the hook "variable" (more concisely, it is
a blessed object), whereas the implicit end of the hook will
automatically be triggered when leaving the scope the hook was
defined in.

 {
     my $hook = Hook::Output::File->redirect(
         stdout => '/tmp/1.out',
         stderr => '/tmp/2.out',
     );
     
     some_sub();

     undef $hook; # explicitly remove hook

     another_sub();
 }
 ... # hook implicitly removed 

=head1 BUGS & CAVEATS

Does not work in a forked environment, such as the case with daemons.

=head1 SEE ALSO

L<perltie>

=head1 AUTHOR

Steven Schubiger <schubiger@cpan.org>

=head1 LICENSE

This program is free software; you may redistribute it and/or
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
