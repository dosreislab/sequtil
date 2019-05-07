#! /usr/bin/perl
# WARNING: THIS PROGRAM SEEMS BROKEN! CHECKED JUNE 2011.
# NOTE: PROGRAM FIXED ON JUN 2012, MORE TESTING NEEDED.
# extractsite.pl 
# A simple program to generate sequences composed only of 1st, 2nd, or 3rd
# codon sites.
#
# (c) 2007-12 Mario dos Reis
#
# v. 0.02

use warnings;
use strict;


my $usage = "usage: extractsite.pl SITE <FASTAIN >FASTAOUT\n";

if (@ARGV < 1) {
    print $usage;
    exit (-1);
}

my $site = $ARGV[0];

if ($site < 1 or $site > 3) {
    die "ERROR: site must be 1, 2 or 3\n" # We only extract 1st, 2nd or 3rd sites.
}

# Funny swapping takes place here!
# Necessary to get correct site extracted! Jun 2012.
if ($site == 1) { $site = 3 }
elsif ($site == 3) { $site = 1 }

my @fastaf = <STDIN>;
my @seqs = ReadFasta (@fastaf);
my @hdrs = getHdrs (@fastaf);

for (my $i = 0; $i < @seqs; $i++) {
    
    my $newseq;
    my $seqlen = length $seqs[$i];
    for (my $l = 0; $l < $seqlen; $l++) {
	if (($l+$site) % 3 == 0) {         # Modified Jun 2012, MdR.
	    $newseq .= substr $seqs[$i], $l, 1;
	}
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
