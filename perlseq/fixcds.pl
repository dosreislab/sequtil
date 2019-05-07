#! /usr/bin/perl

# fixcds.pl
# Fixes cds sequences, adds trailing N's if necessary (to make sequence a
# multiple of three) and remove first, last and stop codons (not everything is
# implemented yet)
#
# v0.01
#
# Copyright (c) 2007 Mario dos Reis

# VERY EXPERIMENTAL, NOT EVERYGHING HAS BEEN TESTED!

use warnings;
use strict;
use Getopt::Std;

my $Usage = 'Usage: fixcds.pl [-flsna] <FASTAIN >FASTAOUT';

# OPTIONS:
# f: Remove first codon
# l: Remove last codon
# s: Replace Stop with NNN
# n: Add trailing Ns
# a: Remove ambiguous characters (gaps, ambiguous nucleotides).
# g: Remove gaps
# i: Remove gaps in first sequence
my %option = ();
getopts("hflsnagi", \%option);

if ($option{'h'}) {
    print "$Usage\nf: remove first codon.\nl: remove last codon.\nn: add trailing Ns.\na: remove ambiguous characters.\ng: remove gaps.\ni: remove gaps if present in first seq only.\n";
    exit;
}

my @file = <STDIN>;
my @sequences = ReadFasta (@file);
my @hdrs = getHdrs (@file);

if ($option{'f'}) {
    @sequences = remove1stCodon (@sequences);
}

# This option should be run before `s' and `l' options
if ($option{'n'}) {
    @sequences = addTrailingNs (@sequences);
}

if ($option{'l'}) {
    @sequences = removeLastCodon (@sequences);
}

if ($option{'s'}) {
    @sequences = replaceStopNNN (@sequences);
}

if ($option{'a'}) {
    @sequences = removeAmbiguous (@sequences);
}

if ($option{'g'}) {
    @sequences = removeGaps (@sequences);
}

if ($option{'i'}) {
    @sequences = removeGapsInFirstSeq (@sequences);
}

for (my $i = 0; $i < @sequences; $i++) {

    print ">", $hdrs[$i], "\n";

    PrintSequence (*STDOUT, $sequences[$i], 80);
}

END;
	       

# ------------ SUBS: -------------------------------------------------

sub addTrailingNs {

    my (@seqs) = @_;

    for (my $i = 0; $i < @seqs; $i++) {
	my $mod = (length $seqs[$i]) % 3;
	if ($mod == 1) { $seqs[$i] .= "NN" }
	if ($mod == 2) { $seqs[$i] .= "N" }
    }
    return @seqs;
}


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

sub PrintSequence {

    my($file, $sequence, $length) = @_;

    for (my $pos = 0; $pos < length($sequence); $pos += $length) {
        print $file substr($sequence, $pos, $length), "\n";
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

# removes starting codon in ORFs
sub remove1stCodon {

    my (@seqs) = @_;
    my $i;

    for ($i = 0; $i < @seqs; $i++) {
	$seqs[$i] = substr($seqs[$i], 3);
    }

    return @seqs;
}

sub removeLastCodon {
    
    my (@seqs) = @_;
    my $i;

    for ($i = 0; $i < @seqs; $i++) {
	$seqs[$i] = substr ($seqs[$i], 0, -3);
    }

    return @seqs;
}

# removes ambiguous characters in nucleotide sequences
sub removeAmbiguous {
 
    my (@seqs) = @_;
    my @newseqs;          # Parsed sequences
    my @nambsites;         # Ambiguous sites
    my $i;

    for ($i = 0; $i < length $seqs[0]; $i++) {

	my $ambiguous = 0;

	foreach my $seq (@seqs) {
	    my $site = substr $seq, $i, 1;
	    if ($site !~ /a|t|c|g/i) {
		$ambiguous = 1;
	    }
	}
	if ($ambiguous == 0) {
	    push @nambsites, $i;
	}
    }

    for ($i = 0; $i < @seqs; $i++) {
	
	my $newseq;
	my $seqlen = length $seqs[$i];
	for (my $j = 0; $j < @nambsites; $j++) {
	    $newseq .= substr $seqs[$i], $nambsites[$j], 1; # watch out index
	}
	push @newseqs, $newseq;
    }
    return @newseqs;
}

# removes gaps characters in nucleotide sequences
sub removeGaps {
 
    my (@seqs) = @_;
    my @newseqs;          # Parsed sequences
    my @nambsites;        # Non-ambiguous sites
    my $i;

    for ($i = 0; $i < length $seqs[0]; $i++) {

	my $ambiguous = 0;

	foreach my $seq (@seqs) {
	    my $site = substr $seq, $i, 1;
	    if ($site =~/-/i) {
		$ambiguous = 1;
	    }
	}
	if ($ambiguous == 0) {
	    push @nambsites, $i;
	}
    }

    for ($i = 0; $i < @seqs; $i++) {
	
	my $newseq;
	my $seqlen = length $seqs[$i];
	for (my $j = 0; $j < @nambsites; $j++) {
	    $newseq .= substr $seqs[$i], $nambsites[$j], 1; # watch out index
	}
	push @newseqs, $newseq;
    }
    return @newseqs;
}

# Remove Gaps found only in the first sequenc (which would be a
# reference sequence)
sub removeGapsInFirstSeq {
    my (@seqs) = @_;
    my @newseqs;          # Parsed sequences
    my @nambsites;        # Non-ambiguous sites
    my $i; my $k;

    for ($i = 0; $i < length $seqs[0]; $i++) {

	my $ambiguous = 0;
        
	# Only check first sequence:
	my $site = substr $seqs[0], $i, 1;
	if ($site =~/-/i) {
	    $ambiguous = 1;
	}
	if ($ambiguous == 0) {
	    push @nambsites, $i;
	}
    }

    for ($i = 0; $i < @seqs; $i++) {
	
	my $newseq;
	my $seqlen = length $seqs[$i];
	for (my $j = 0; $j < @nambsites; $j++) {
	    $newseq .= substr $seqs[$i], $nambsites[$j], 1; # watch out index
	}
	push @newseqs, $newseq;
    }
    return @newseqs;
}

# Replaces stop codons with NNN
sub replaceStopNNN {

    my (@seqs) = @_;

    for (my $i = 0; $i < @seqs; $i++) {
	for (my $j = 0; $j < length($seqs[$i]) - 2; $j += 3) {

	    my $codon = substr $seqs[$i], $j, 3;
	    if ($codon =~ /taa|tag|tga/i) {
		substr($seqs[$i], $j, 3) = "NNN";
	    }
	}
    }
    return @seqs;
}



# NOT IMPLEMENTED YET
sub removeStop {

    my (@seqs) = @_;

    for (my $i = 0; $i < @seqs; $i++) {
	for (my $j = 0; $j < length($seqs[$i]) - 2; $j += 3) {

	    my $codon = substr $seqs[$i], $j, 3;
	    if ($codon =~ /taa|tag|tga/i) {
		$seqs[$i] = substr($seqs[$i], 0, $j) . substr($seqs[$i], $j+3);
		$j -= 3;
	    }
	}
    }
    return @seqs;
}
#
