#! /usr/bin/perl

# simpledist
#
# A simple program to generate a (lower triangular) matrix
# of distances for sequences in a FastA file. Sequences must
# be aligned. But watch out, although this IS a lower triangular
# matrix, it is NOT printed to STDOUT in that way!
#
# (c) 2007 Mario dos Reis

use warnings;
use strict;
use Getopt::Std;

my %Options;
getopts("hp", \%Options);

if ($Options{'h'}) 
{ 
    print STDOUT
"simpledist:

        Usage: simpledist [-m] <FASTAIN >DISTOUT

           -p: use the simple p distance (proportion of different amino acid sites), by default
               Kimura's Dayhoff aproximation is used. See the source code for details.
";
    exit -1;
}

my @seqs = ReadFasta(<STDIN>);
my $dist;

for (my $i = 0; $i < @seqs - 1; $i++) {

    print STDERR "Analysing seq ", $i + 1, " ...";

    for (my $j = $i +1; $j < @seqs; $j++) {

	#check that sequences have same length
	if (length $seqs[$i] != length $seqs[$j]) {
	    print STDERR "ERROR: Sequences in alignment must be of same length\n";
	    exit -1;
	}

	# now calculate their distance
	$dist = ($Options{'p'}) ? Distance($seqs[$i], $seqs[$j]) : Kimura($seqs[$i], $seqs[$j]);

	print $dist, "\t";
    }
    print STDERR " done\n";
    print "\n";
}

#--------------- SUBS: -----------------------

# calculates distance for two seqs 'a' and 'b'
# check that 'a' and 'b' have the same length before calling this
# subroutine
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

# Kimura's Dayhoff approximation, see:
# 'The Neutral Theory of Molecular Evolution'
# Motoo Kimura, Cambridge Univ. Press (1983)
# chapter 4, p.75
sub Kimura {

    my ($a, $b) = @_;

    my $len_a = length $a;
    my $distance = 1;
    my $ndiff = 0;    # number of differences
    my $p = 0;

    # if sequences are identical, return 1 as the distance
    if ($a eq $b) {
	return 0;
    }
    else {

	for (my $i = 0; $i < $len_a; $i++) {
	    if ((substr $a, $i, 1) ne (substr $b, $i, 1)) {
		$ndiff++;
	    }
	}
	
	$p = $ndiff / $len_a;
	$distance = -log( 1 - $p - 0.2 * ($p**2) );
	return $distance;
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
