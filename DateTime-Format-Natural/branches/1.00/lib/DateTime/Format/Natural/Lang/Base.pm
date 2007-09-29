package DateTime::Format::Natural::Lang::Base;

use strict;
use warnings;
use base qw(Exporter);

our $VERSION = '0.4';
our @EXPORT = qw(AUTOLOAD __new);
our $AUTOLOAD;

sub __new 
{
    my $class = shift;

    no strict 'refs';

    my $obj = {};
    $obj->{weekdays}        = \%{$class.'::'.'data_weekdays'};
    $obj->{weekdays_abbrev} = \%{$class.'::'.'data_weekdays_abbrev'};
    $obj->{months}          = \%{$class.'::'.'data_months'};
    $obj->{months_abbrev}   = \%{$class.'::'.'data_months_abbrev'};

    return bless $obj, ref($class) || $class;
}

AUTOLOAD 
{
    my ($self, $exp) = @_;

    my ($caller) = $AUTOLOAD =~ /(.*)::.*/;
    my $sub = $AUTOLOAD;
    $sub =~ s/^.*:://;

    if (substr($sub, 0, 2) eq '__') {
       $sub =~ s/^__//;
       no strict 'refs';
       if (defined $exp && length $exp) {
           return ${$caller.'::'.$sub}{$exp};
       }
       else {
           return \%{$caller.'::'.$sub};
       }
    }
}

1;
__END__

=head1 NAME

DateTime::Format::Natural::Lang::Base - Base class for DateTime::Format::Natural::Lang::

=head1 SYNOPSIS

 Please see the DateTime::Format::Natural::Lang:: documentation.

=head1 DESCRIPTION

The C<DateTime::Format::Natural::Lang::Base> module defines the core functionality for
C<DateTime::Format::Natural::Lang::> classes.

=head1 SEE ALSO

L<DateTime::Format::Natural::Lang::>, L<DateTime>, L<Date::Calc>, L<http://datetime.perl.org>

=head1 AUTHOR

Steven Schubiger <schubiger@cpan.org>

=head1 LICENSE

This program is free software; you may redistribute it and/or
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
