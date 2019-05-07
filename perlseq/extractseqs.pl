#! /usr/bin/perl
#
# Extract sequences
# A program to extract a reduced number of sequences
# from a larger collection in a FastA file
#
# (c) 2007 Mario dos Reis
#
# v 0.02

use warnings;
use strict;

my $usage = "extractseqs.pl SEQPOSFILE <FASTAFILE >OUTFILE";

# SEQFILE contains the sequence positions to be extracted

unless (@ARGV) {

    print "Usage: $usage\n";
    exit -1;
}

my @fasta = <STDIN>;

my @seqs = ReadFasta(@fasta);

my @hdrs = ReturnNames(@fasta);

my $seqsfile = $ARGV[0];

open SEQS, $seqsfile
    or die "FATAL: could not open file $seqsfile: $!\n";

my @seqpos = (<SEQS>);

chomp (@seqpos);

foreach my $pos (@seqpos) {
    
    print STDOUT ">$hdrs[$pos-1]\n";

    PrintSequence($seqs[$pos-1], 80); # pos in 'seqpos' starts at one, in perl arrays we start at zero
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
