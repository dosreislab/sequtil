#! /usr/bin/perl

# Fasta to Nexus:
# Program to convert a fasta alignment file to
# the nexus format suitable for input into 
# Mr. Bayes
#
# Mario dos Reis Feb 2007
#
# v0.01


use warnings;
use strict;

my $usage = "$0 LABELSFILE TYPE <INFILE >OUTFILE";
# TYPE is either dna, rna, protein, standard, restriction


unless (@ARGV > 1) {
    
    print "Usage: $usage\n";
    exit -1;
}

my @seqs = ReadFasta(<STDIN>);

CheckLength(@seqs);

my $labelsfile = $ARGV[0];

open LABELS, $labelsfile
    or die "FATAL: could not open file $labelsfile: $!\n";
my @labels = <LABELS>;

chomp @labels;

my $nseqs = (@seqs);
my $seqlen = length $seqs[1];

print STDOUT
"#NEXUS
begin data;
dimensions ntax=$nseqs  nchar=$seqlen;
format datatype=$ARGV[1] interleave=no gap=-;
matrix
";

for (my $i = 0; $i < @seqs; $i++) {

    print STDOUT $labels[$i], "     ", $seqs[$i], "\n";
}

print STDOUT
";
end;
";

close LABELS;

END;

#--------------- SUBS: -----------------------

sub CheckLength {

    my (@seqs) = @_;

    my $sqlen = length $seqs[0];

    foreach my $seq (@seqs) {

	if (length ($seq) != $sqlen) {

	    print STDERR "ERROR: Sequences in alignment must be of same length\n";

	    exit -1;
	}
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
