package Acme::Text::Rhombus;

use strict;
use warnings;
use base qw(Exporter);

our ($VERSION, @EXPORT_OK);

$VERSION = '0.17';
@EXPORT_OK = qw(rhombus);

sub rhombus {
    my %opts = @_;    
    my ($rhombus, $lines, $letter, $case, $fillup);
    
    $lines  = $opts{lines}  ||      25;
    $letter = $opts{letter} ||     'a';
    $case   = $opts{case}   || 'upper'; 
    $fillup = $opts{fillup} ||     '+'; 
        
    $letter = $case eq 'upper' ? uc($letter) : lc($letter);   
    $lines++ if $lines % 2 == 0;
    
    my ($line, $repeat) = (1,1);
    for (; $line <= $lines; $line++) {
        my $space = ($lines - $repeat) / 2;
	my $fillup_space = $fillup x $space;
	
	$rhombus .= $fillup_space;
        $rhombus .= $letter x $repeat; 
        $rhombus .= "$fillup_space\n";
	
	$repeat = $line < ($lines / 2) ? $repeat + 2 : $repeat - 2;
        $letter = chr(ord($letter) + 1);

        if ($letter !~ /[a-z]/i) {
	    $letter = $case eq 'upper' ? 'A' : 'a';
	}
    }    
    return $rhombus;
}

1;
__END__

=head1 NAME

Acme::Text::Rhombus - Draw an alphanumerical rhombus

=head1 SYNOPSIS

 use Acme::Text::Rhombus qw(rhombus);

 print rhombus(
     lines   =>       31,
     letter  =>      'c',
     case    =>  'upper',
     fillup  =>      '+',
 );

 __OUTPUT__

 ++++++C++++++
 +++++DDD+++++
 ++++EEEEE++++
 +++FFFFFFF+++
 ++GGGGGGGGG++
 +HHHHHHHHHHH+
 IIIIIIIIIIIII
 +JJJJJJJJJJJ+
 ++KKKKKKKKK++
 +++LLLLLLL+++
 ++++MMMMM++++
 +++++NNN+++++
 ++++++O++++++

=head1 FUNCTIONS

=head2 rhombus

Draws an alphanumerical rhombus and returns it as string. 
Omitting options will return a rhombus of 25 lines.

Options:

=over 4

=item lines

Amount of lines to be printed.

=item letter

Alphanumerical letter to start with.

=item case

Lower/upper case of the letters within the rhombus.

=item fillup

The fillup character.

=back

=head1 AUTHOR

Steven Schubiger <schubiger@cpan.org>

=head1 LICENSE

This program is free software; you may redistribute it and/or 
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>	    

=cut
