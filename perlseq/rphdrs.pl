#! /usr/bin/perl

# Replace Headers a program to replace
# the headers in a FastA format file
#
# (c) 2007 Mario dos Reis
#
# v0.01

use warnings;
use strict;

my $usage = "rphdrs.pl LABELSFILE <INFILE >OUTFILE";

unless (@ARGV) {

    print "Usage: $usage\n";
    exit -1;
}

my @fasta = <STDIN>;

my $labelsf = $ARGV[0];

open LABELS, $labelsf
    or die "FATAL: could not open file $labelsf: $!\n";

my @labels = <LABELS>;

chomp @labels;

my $i = 0;

foreach my $line (@fasta) {

    if ($line =~ />/) {
	
	print STDOUT ">", $labels[$i], "\n";
	$i++;
    }
    else {
	print STDOUT $line;
    }
}

close LABELS;

END;
