#! /usr/bin/perl

# extracsites.pl
# Similar, but not quite the same, as extractsite.pl.
# This program extracts the sites defined in a sites file from 
# a sequence alignment.
#
# (c) 2007 Mario dos Reis
#
# v 0.01

use warnings;
use strict;

my $usage = "usage: extractsites.pl SITEFILE <FASTAIN >FASTAOUT\n";

if (@ARGV < 1) {
    print $usage;
    exit (-1);
}

unless (open(SITEFILE, $ARGV[0])) {
    print STDERR "fatal: could not open file $ARGV[0] for reading.\n";
}

my @sites = <SITEFILE>;

my @fastaf = <STDIN>;
my @seqs = ReadFasta (@fastaf);
my @hdrs = getHdrs (@fastaf);

for (my $i = 0; $i < @seqs; $i++) {
    
    my $newseq;
    my $seqlen = length $seqs[$i];
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
