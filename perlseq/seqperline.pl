#! /usr/bin/perl

#
# Takes a fasta file and prints each sequence (without
# headers) in a single line.
#
# Jan 2007 v 0.01

my @seqs = ReadFasta(<STDIN>);

foreach my $line (@seqs) {

    print "$line\n";
}

# ------------- SUBS: ----------------------

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
