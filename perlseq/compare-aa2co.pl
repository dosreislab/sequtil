#! /usr/bin/perl
 
# Compare Aminoacid FastA file against
# a codon FastA file, to check if both
# files are congruent.
#
# (c) 2007 Mario dos Reis 
#
# v0.03

use warnings;
use strict;

my $usage = "Usage: compare-aa2co.pl AAFILE CODONFILE";

unless (@ARGV > 1) {

    print STDERR $usage, "\n";
    exit -1;
}

my $aafile = $ARGV[0];
my $codonfile = $ARGV[1];

open AAFILE, $aafile
    or die "Error: could not open file $aafile: $!\n";

open CODONFILE, $codonfile
    or die "Error: could not open file $codonfile: $!\n";

my @cof = <CODONFILE>;
my @aa = ReadFasta(<AAFILE>);
my @co = ReadFasta(@cof);
my @hd = getHdrs(@cof);

# Main stuff takes place here, codons are translated and
# compared to the respective aa sequence. Amino acids must
# be in one letter code, stops are '*' and gaps are '-'

my $status = 0; #every thing's ok

for (my $i = 0; $i < (@co); $i++) {

    if ((length($co[$i]) % 3) != 0) {
	print STDERR "warning: sequence ", $i+1,
	": $hd[$i]: length is not multiple of three\n";
	$status = 1;
    }

    my $newaa = Translate($co[$i]);

    # remove STOP codon from translation if any
    if (substr($newaa, -1, 1) eq "*") {
	$newaa = substr $newaa, 0, -1;
    }

    if (length $newaa != length $aa[$i]) {
	print STDERR "warning: sequence ", $i+1,
	": $hd[$i]: translation has different length than aa sequence.\n";
	$status = 1;
	#next;
    }

    my $dist = Distance ($aa[$i], $newaa);

    if ($dist > 0) {
	print STDERR "warning: sequence ", $i+1, ": $hd[$i]",
	": codon sequence does not translate properly into aa sequence, d=$dist\n";
	$status = 1;
    }
}

if ($status == 0) {
    print STDOUT "Check sucessfull! Sequences are congruent.\n";
}
   
close AAFILE;
close CODONFILE;

END;

# -------------------- SUBS: -----------------------------

##########################################################
# Reading FastA files and retrieving their headers
##########################################################

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

#####################################################
# Translates a given dna sequence into its
# respective protein sequence.
# WARNING: dna should be in string format, and free
#          of white spaces, new lines, etc.
#####################################################

sub Translate {
    my($dna) = @_;
    my $protein = '';
    my $codon = '';

    for (my $i = 0; $i < length($dna) - 2; $i += 3) {
	$codon = substr($dna, $i, 3);
	$protein .= Codon2aa($codon);
    }
    return $protein;
}

#####################################################
# Translates a given codon into its respective aa
#####################################################

sub Codon2aa {
    my($codon) = @_;

       if ($codon =~ /tt[tc]/i)      { return 'F' }
    elsif ($codon =~ /tt[ag]|ct./i)  { return 'L' }
    elsif ($codon =~ /tc.|ag[tc]/i)  { return 'S' }
    elsif ($codon =~ /ta[tc]/i)      { return 'Y' }
    elsif ($codon =~ /ta[ag]|tga/i)  { return '*' }
    elsif ($codon =~ /tg[tc]/i)      { return 'C' }
    elsif ($codon =~ /tgg/i)         { return 'W' }
    elsif ($codon =~ /cc./i)         { return 'P' }
    elsif ($codon =~ /ca[tc]/i)      { return 'H' }
    elsif ($codon =~ /ca[ag]/i)      { return 'Q' }
    elsif ($codon =~ /cg.|ag[ag]/i)  { return 'R' }
    elsif ($codon =~ /at[tca]/i)     { return 'I' }
    elsif ($codon =~ /atg/i)         { return 'M' }
    elsif ($codon =~ /ac./i)         { return 'T' }
    elsif ($codon =~ /aa[tc]/i)      { return 'N' }
    elsif ($codon =~ /aa[ag]/i)      { return 'K' }
    elsif ($codon =~ /gt./i)         { return 'V' }
    elsif ($codon =~ /gc./i)         { return 'A' }
    elsif ($codon =~ /ga[tc]/i)      { return 'D' }
    elsif ($codon =~ /ga[ag]/i)      { return 'E' }
    elsif ($codon =~ /gg./i)         { return 'G' }
    elsif ($codon =~ /---/)          { return '-' }
                                else { return 'X' }
}

#################################################################
# Calculates distance for two seqs 'a' and 'b'
# check that 'a' and 'b' have the same length before calling this
# subroutine
#################################################################

sub Distance {

    my ($a, $b) = @_;

    my $len_a = length $a;
    my $distance = 1;
    my $ndiff = 0;    # number of differences

    # if sequences are identical, return 1 as the distance
    if ($a eq $b) {
	return 0;
    }
    else {

	for (my $i = 0; $i < $len_a; $i++) {
	    # ignore gaps:
	    if ((substr $a, $i, 1) eq '-' || (substr $b, $i, 1) eq '-') {
		next;
	    }
	    if ((substr $a, $i, 1) ne (substr $b, $i, 1)) {
		$ndiff++;
	    }
	}

	$distance = $ndiff / $len_a;
	return $distance;
    }
}
