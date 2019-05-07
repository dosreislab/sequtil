#! /usr/bin/perl -w
#
# Program to extract subsequence regions from fasta files
#
# usage $ subseq.pl begin:end <infile >outfile

use strict;

my $usage = "$0 start:end <infile >outfile";

unless(@ARGV) {
    print "usage: $usage\n";
    exit -1;
}

my $limits = $ARGV[0];
my $inverted = 0;

$limits =~ /(\d+):(\d+)/;

my ($begin, $end) = ($1, $2);

if ($begin >= $end) {
    $inverted = 1;
    ($begin, $end) = ($end, $begin);
}

my ($seq) = ReadFasta(<STDIN>);
# + and - 1's are needed to correct for array coordinates (starting at 0)
my $subseq = substr $seq, $begin-1, $end-$begin+1;

if ($inverted == 1) {
    $subseq =~ tr/ATUCGatucg/TAAGCtaagc/;
}

print ">subseq $begin:$end\n";
PrintSequence($subseq, 60);

# SUBS ##################################################################

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

    #print $seqs[4288], "\n";

    #print scalar @seqs, "\n";

    return @seqs;
}

sub PrintSequence {

    my($sequence, $length) = @_;

    for (my $pos = 0; $pos < length($sequence); $pos += $length) {
	print substr($sequence, $pos, $length), "\n";
    }
}
