#! /usr/bin/perl

# Paste a list of sequences in a FastA
# file into a single long sequence.
#
# (c) 2010 Mario dos Reis
#
# v0.01

use warnings;
use strict;

my $usage = "seqpaste.pl <INFILE >OUTFILE";

my @fasta = <STDIN>;

my $i = 0;

print ">Pasted sequences\n";

foreach my $line (@fasta) {

    if ($line =~ />/) {
	;  # do nothing
    }
    else {
	print STDOUT $line;
    }
}

END;
