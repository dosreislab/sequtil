#! /usr/bin/perl

# (c) 2007 Mario dos Reis
#
# shuffleseqs.pl a program to shuffle the position of sequences in a FastA file

# Usage: shuffleseqs.pl <INFASTA >OUTFASTA

use warnings;
use strict;

use List::Util 'shuffle';

my @fasta = <STDIN>;

my @seqs = ReadFasta(@fasta);
my @hdrs = ReturnNames(@fasta);

my @seqpos;

for (my $i = 0; $i < @seqs; $i++) {
    
    push @seqpos, $i;
}

my @shufflepos = shuffle (@seqpos);

foreach my $pos (@shufflepos) {
    
    print STDOUT ">$hdrs[$pos]\n";
    PrintSequence($seqs[$pos], 80);

}

END;

#--------------- SUBS: -----------------------

sub PrintSequence {

    my($sequence, $length) = @_;

    for (my $pos = 0; $pos < length($sequence); $pos += $length) {
        print substr($sequence, $pos, $length), "\n";
    }
}

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


sub ReturnNames {

    my (@file) = (@_);
    my @names;
    
    foreach my $line (@file) {
        if($line =~ />/) {
            chomp($line);
            $line = substr $line, 1;
            push @names, $line;
        }
    }
    return @names;
}
