#! /usr/bin/perl

# Replace Headers a program to replace
# the headers in a FastA format file
#
# (c) 2007 Mario dos Reis
#
# v0.01

use warnings;
use strict;

my $usage = "rphdrs.pl <INFILE >OUTFILE";

my $i = 0;
my $j = 1;

foreach my $line (<STDIN>) {

    if ($line =~ />/) {
	
	print STDOUT ">", $j, "\n";
	$i++;
	$j++;
    }
    else {
	print STDOUT $line;
    }
}

END;
