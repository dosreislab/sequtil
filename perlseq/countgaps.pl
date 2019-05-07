#! /usr/bin/perl -w
# Count the number of gaps per sequence in
# a FastA file.
# MdR April 2009
# Usage: countgaps.pl <FASTAFILE
use strict;

my $count = 0;
my $first = 0;
foreach my $line (<>)
{
    if ($line =~ /^>/) { 
	print $count, "\n" if $first;
	$count = 0; $first = 1; 
	next 
    }
    $count += $line =~ tr/-//;
}
print $count, "\n";
