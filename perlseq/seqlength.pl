#! /usr/bin/perl

# seqlength.pl a program to calculate the length of sequences in
# FastA formatted file

# usage: seqlength.pl <INFASTA >LENGTHSOUT

use warnings;
use strict;

my @fasta = <STDIN>;

my @seqs = ReadFasta(@fasta);

foreach my $seq (@seqs) {

    print length $seq, "\n";
}

END;

sub ReadFasta {

    my (@file) = @_;;
    
    my @seqs;
    
    my $seq = "";
    
    # load sequences
    foreach my $line (@file) {
	
	if ($line =~ />/) {
	    chomp($seq);
	    push(@seqs, $seq);
	    $seq = "";
	    next;
	
	} else {

	    $line =~ s/\s//;
	    $seq = $seq.$line;
	    
	}
    }

    # add last sequence
    chomp($seq);
    push(@seqs, $seq);
    
    # delete first element of the array (empty sequence)
    shift @seqs;

    return @seqs;
}
