#!/usr/bin/perl

use strict;
use warnings;

use Math::Factor::XS qw(factors matches);

our ($Skip_multiple, $i, $matches, $ul, %form);

#$Math::Factor::XS::Skip_multiple = 1;

my $number = 30107;
    
my @factors = factors($number);
my @matches = matches($number, @factors);

show_factors($number, \@factors);
show_matches($number, \@matches);

sub show_factors {
    my ($number, $factors) = @_;

    print <<'HEADER';
-------
factors
-------

HEADER
     
    local $ul = '-' x length($number);
	
    formeval('factors');
    write; 
    
    local $, = "\t"; 
    print "@$factors\n\n";
}

sub show_matches {
    my ($number) = shift;
    local ($matches) = @_;   
	
    print <<'HEADER';
-------
matches
-------

HEADER

    local $ul = '-' x length($number);
	
    formeval('match_number'); 
    write;
    
    formeval('match_matches'); 
    for (local $i = 0; $matches->[$i]; $i++) { write }
    print "\n";
}    

sub formeval {
    my ($ident) = @_;
    
    no warnings 'redefine';
    eval $form{$ident};
    die $@ if $@;
}

BEGIN {
    $form{factors} = '
    format =
@<<<<<<<<<<<<<<<<<<<<<<<<<
$number
@<<<<<<<<<<<<<<<<<<<<<<<<<
$ul
.';

    $form{match_number} = '
    format =
@<<<<<<<<<<<<<<<<<<<<<<<<<
$number
@<<<<<<<<<<<<<<<<<<<<<<<<<
$ul
.';

    $form{match_matches} = '
    format =
@<<<<<<<<<<<* @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$matches->[$i][0], $matches->[$i][1]
.';
}
