#! /usr/bin/perl
#
#  format-align.pl v0.3
#
#  A script to format alignments in FastA format, the output is phylip
#  sequential.
#
#  Use option 'co' to format codon aligned DNA sequences
#
#  Inherits code from the ancient script to format ortholog alignments
#  in the E.coli landscape analysis.
#
#
#  (c) 2007 Mario dos Reis

use strict;
use warnings;

my $spacer = 10;
my $len = 120; # subsequence length for printing

if (@ARGV > 0 && $ARGV[0] eq 'co') { $spacer = 3; $len = 90 }

my @fasta = <STDIN>;

my @seqs = ReadFasta(@fasta);
#my @hdrs = getHdrs(@fasta);

CheckLength(@seqs);

my @formated_seqs = FormatAlignment(@seqs);

# print preliminary information
print "\t", scalar @formated_seqs, "\t",
length $formated_seqs[1], "\tI\n"; # I for interleaved

# # print sequence names
# foreach my $hdr (@hdrs) {
#     print "$hdr\n";
# }

# PRINT FORMATTED SEQUENCES:
my $bpos = 0; # base position in alignment

for(my $i = 0; $i < length $formated_seqs[1]; $i += $len) {
    
    print  "\npos:\t", $bpos + 1, "\n";
    
    for (my $j = 0; $j < @formated_seqs; $j++) {

	my $seq = $formated_seqs[$j];

	# print sequence number at begining of line
	print $j + 1, "\t";
	
	for(my $pos = $bpos; $pos < $bpos + length substr($seq, $bpos, $len); 
	    $pos += $spacer) {
	    print  substr($seq, $pos, $spacer), " ";
	}
	print  "\n"; # start new line
    }
    $bpos += $len; # update position
}


##### SUBS start here ########################################

sub FormatAlignment {

    my @seqs = @_;
    my $master = $seqs[0]; # master sequence
    my @fseqs = ($master); # formatted sequences
    shift @seqs; # remove master sequence

    foreach my $seq (@seqs) {

	my $fseq = ""; # formatted sequence

	for(my $pos = 0; $pos < length($master); $pos++) {
	    if(substr($master, $pos, 1) eq "-") {
		$fseq .= substr($seq, $pos, 1);
	    }
	    elsif(substr($master, $pos, 1) eq substr($seq, $pos, 1)) {
		if (substr($master, $pos, 1) eq "*") {
		    $fseq .= "*";
		}
		else {
		    $fseq .= ".";
		}
	    } else {
		$fseq .= substr($seq, $pos, 1);
	    }
	}
	push @fseqs, $fseq;
    }
    return @fseqs;
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

sub ReadFasta {
 
    my (@file) = @_;
     
    my @seqs;
    my @hdrs;
     
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
 
    #print scalar @seqs, "\n";
 
    return @seqs;
}

# Removes gaps from alignments, this
# sub is probably inefficient but it works right!
# should try to come up with a better solution
sub nogaps {

    my (@seqs) = @_;
    my @pos;

    foreach my $seq (@seqs) {
	while ($seq =~ /-{3}/og) {
	    push @pos, pos($seq)-3;
	    #print pos($seq) - 3, "\n";
	}
    }
    foreach my $seq (@seqs) {
	foreach my $pos (@pos) {
	    substr $seq, $pos, 3, "---";
	}
    }
    for (my $i = 0; $i < @seqs; $i++) {
	$seqs[$i] =~ s/-//og;
	#print "$seqs[$i]\n";
    }
    return @seqs;
}

# Replaces STOP codons with NNN
sub noSTOP {

    my (@seqs) = @_;

    for (my $j = 0; $j < @seqs; $j++) {
	for (my $i = 0; $i < length($seqs[$j]) - 2; $i = $i + 3) {
	    if (substr($seqs[$j], $i, 3) =~ /(TGA)|(TAA)|(TAG)/oi) {
		substr $seqs[$j], $i, 3, "NNN";
	    }
	}
    }

    return @seqs;

}

    
sub CheckLength {

    my (@seqs) = @_;

    my $sqlen = length $seqs[0];

    foreach my $seq (@seqs) {

	if (length ($seq) != $sqlen) {

	    die ("seqlength.pl: error: Sequences in alignment must be of same length\n");

	}
    }
}
