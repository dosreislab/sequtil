#! /usr/bin/perl

# fasta2phys-compled.pl
# A program to take alignments in fastA format
# and transform them to Phylip sequential format
# This version chomps headers
#
# v.0.03 -- Ignores comments
# (c) 2007, 2016  Mario dos Reis
#

use warnings;
use strict;

my $usage = "Usage:fasta2phys.pl LABELSFILE <INFILE >OUTFILE"; 

unless (@ARGV) {
    
    print STDOUT $usage, "\n";
    exit -1;
}

my @seqs = ReadFasta(<STDIN>);

my $nseqs = (@seqs);
my $sqlen  = length $seqs[0];

CheckLength(@seqs);

my $labelsfile = $ARGV[0];

open LABELS, $labelsfile
    or die "FATAL: could not open file $labelsfile: $!\n";
my @labels = <LABELS>;

chomp @labels;

# print number of seqs and seq length
print STDOUT "   $nseqs $sqlen\n";

my $n = 0;
# print sequences (needs improvement)
foreach my $seq (@seqs) {

    print STDOUT $labels[$n], "  $seq\n";
    $n++;
}

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

	if ($line =~ /#/) {
	    next;
	}
	
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

