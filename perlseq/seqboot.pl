#! /usr/bin/perl

# seqboot.pl
# Bootstrap sequences.
# This program is a descendant from extractsites.pl
#
#
# (c) 2007 Mario dos Reis
# 
# v 0.01

use warnings;
use strict;

# usage: seqboot.pl <FASTAIN >FASTAOUT

my @fastaf = <STDIN>;
my @seqs = ReadFasta (@fastaf);
my @hdrs = getHdrs (@fastaf);

my $seqlen = length $seqs[0];
my @sites;

for (my $i = 0; $i < $seqlen; $i++) {

    push @sites, int rand $seqlen;
}

for (my $i = 0; $i < @seqs; $i++) {
    
    my $newseq;
    for (my $j = 0; $j < @sites; $j++) {
	$newseq .= substr $seqs[$i], $sites[$j] - 1, 1;
    }
    
    print ">$hdrs[$i]\n";

    PrintSequence (*STDOUT, $newseq, 80);
}

END;

# ------------------------ SUBS:

sub getHdrs {

    my(@file) = @_;
    my @hdrs;

    foreach my $line (@file) {
 
        if ($line =~ />(.+)/) {
	    push @hdrs, $1;
	}
    }
    return @hdrs;
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

sub PrintSequence {

    my($file, $sequence, $length) = @_;

    for (my $pos = 0; $pos < length($sequence); $pos += $length) {
        print $file substr($sequence, $pos, $length), "\n";
    }
}
