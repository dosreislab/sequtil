#! /usr/bin/perl

# seqcathdrs.pl:
# A program to concatenate sets of sequences from different
# FastA files. Suppose file A contains 10 sequences, and file B also
# contains 10 sequences, then after
# $ seqcat.pl A B >AB
# file AB contains 10 sequences where each of its members is a concatenation
# of the corresponding sequences in A and B.
#
# v0.02
#
# Copyright (c) 2007 Mario dos Reis
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

use warnings;
use strict;

my $usage =
    "usage: seqcat.pl FASTA1 FASTA2 [...]\n";

# we need at least two FastA files!
unless (@ARGV > 1) {
    print $usage;
    exit (-1);
}

my @file;
my @hdrs; # Headers from first FastA file

my @fastaf;

for (my $i = 0; $i < @ARGV; $i++) {

    open (FILE, "< $ARGV[$i]")
	or die "Could not open $ARGV[$i] for reading: $!\n";

    @file = readline(*FILE);
    $fastaf[$i] = [ ReadFasta(@file) ];

    # get headers
    if ($i == 0) { @hdrs = getHdrs(@file); }

    close(FILE);
}

my @cseqs; # concatenated sequences
my @nfiles = @fastaf;  # number of files being processed
my $ref = $fastaf[0]; # trick to get number of seqs in $fastaf[0]

for (my $j = 0; $j < @$ref; $j++) {
    for (my $i = 0; $i < @nfiles; $i++) {
	$cseqs[$j] .= $fastaf[$i][$j];
    }
}

for (my $i = 0; $i < @cseqs; $i++) {
    
    print ">", $hdrs[$i], "\n"; # use proper headers
    PrintSequence(*STDOUT, $cseqs[$i], 80000);
}

# --------- SUBS: ---------------------------------------------------

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

