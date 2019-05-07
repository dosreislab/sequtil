#! /usr/bin/perl

# Program to perform DNA translation in ONE frame using mit genetic code.
#
# (c) 2007, 2015 Mario dos Reis

# usage: translate-mit.pl FRAME <FASTAIN >FASTAOUT # only positive frames allowed
# NOTE: Testing needed, Feb 2015.

use warnings;
use strict;

my @fasta = <STDIN>;
my @seqs = ReadFasta (@fasta);
my @hdrs = getHdrs (@fasta);
my $frame = 0;

if (@ARGV > 0) {
    $frame = $ARGV[0] - 1;
}

for (my $i = 0; $i < @seqs; $i++) {

    if ((length $seqs[$i]) % 3 != 0) {
	print STDERR "warning: sequence ", $i+1, ": $hdrs[$i]: not a multiple of three!\n";
	print ">", $hdrs[$i], " (unreliable translation)\n";
    }
    else {
	print ">", $hdrs[$i], "\n";
    }

    my $prot = Translate ($seqs[$i], $frame);

    PrintSequence ($prot, 80);
}

END;

# ----------  SUBS START HERE: ----------------------

#####################################################
# Translates a given codon into its respective aa
#####################################################

sub Codon2aa {
    my($codon) = @_;

       if ($codon =~ /-/i)           { return '-' }
    elsif ($codon =~ /tt[tc]/i)      { return 'F' }
    elsif ($codon =~ /tt[ag]|ct./i)  { return 'L' }
    elsif ($codon =~ /tc.|ag[tc]/i)  { return 'S' }
    elsif ($codon =~ /ta[tc]/i)      { return 'Y' }
    elsif ($codon =~ /ta[ag]/i)      { return '*' }
    elsif ($codon =~ /ag[ag]/i)      { return '*' }
    elsif ($codon =~ /tg[tc]/i)      { return 'C' }
    elsif ($codon =~ /tg[ga]/i)      { return 'W' }
    elsif ($codon =~ /cc./i)         { return 'P' }
    elsif ($codon =~ /ca[tc]/i)      { return 'H' }
    elsif ($codon =~ /ca[ag]/i)      { return 'Q' }
    elsif ($codon =~ /cg.|ag[ag]/i)  { return 'R' }
    elsif ($codon =~ /at[tc]/i)      { return 'I' }
    elsif ($codon =~ /at[ag]/i)      { return 'M' }
    elsif ($codon =~ /ac./i)         { return 'T' }
    elsif ($codon =~ /aa[tc]/i)      { return 'N' }
    elsif ($codon =~ /aa[ag]/i)      { return 'K' }
    elsif ($codon =~ /gt./i)         { return 'V' }
    elsif ($codon =~ /gc./i)         { return 'A' }
    elsif ($codon =~ /ga[tc]/i)      { return 'D' }
    elsif ($codon =~ /ga[ag]/i)      { return 'E' }
    elsif ($codon =~ /gg./i)         { return 'G' }
                                else { return 'X' }
}

#####################################################
# Translates a given dna sequence into its
# respective protein sequence.
# WARNING: dna should be in string format, and free
#          of white spaces, new lines, etc.
#####################################################

sub Translate {
    my ($dna, $frame) = @_;
    my $protein = '';
    my $codon = '';

    for (my $i = $frame; $i < length($dna) - 2; $i += 3) {
	$codon = substr($dna, $i, 3);
	$protein .= Codon2aa($codon);
    }
    return $protein;
}

######################################################
# Prints a sequence according to a predetermined line
# length. For example if '$sequence' is a very long 
# string, say 1000bp, then it will be printed in a
# very long line; this subroutine, prints that
# sequence in for example, lines of 80 char.
######################################################

sub PrintSequence {

    my($sequence, $length) = @_;

    for (my $pos = 0; $pos < length($sequence); $pos += $length) {
	print substr($sequence, $pos, $length), "\n";
    }
}

######################################################
# Get sequences and fasta headers (two subs).
######################################################

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
