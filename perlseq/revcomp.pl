#! /usr/bin/perl
#
#############################################################
# This program is designed get the reverse complement
# from DNA, RNA
#
# (c) 2011 Mario dos Reis
#
# version 0.0
# usage: revcomp.pl <INFILE >OUTFILE
#############################################################

use strict;

my @infile = <STDIN>;

my @sequences = ReadFasta (@infile);
my @hdrs = getHdrs (@infile);

for (my $i = 0; $i < @sequences; $i++) {

    print ">", $hdrs[$i], "\n";

    my $revseq = GetRevComp ($sequences[$i]);

    PrintSequence (*STDOUT, $revseq, 80);
}

END;

#############################################################
# SUBS:
#############################################################

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


# Gets the reverse complement of a DNA sequence
sub GetRevComp {

	my($dna) = @_;
	
	#reverses the DNA strand
	my $revcomp = reverse $dna;
	
	#substitutes for the respective nucleotides
	$revcomp =~ tr/ACGTUacgtu/TGCAAtgcaa/;

	#substitutes any unknown nucleotide by 'n';
	$revcomp =~ s/[^acgt?-]/N/ig;

	return $revcomp;
}
