# SeqUtil

A set of Perl and Bash scripts to work with molecular sequences.

The scripts should work "out of the box" in any Unix system. That is, without
the need for installing any libraries or additional scripts.

These scripts were written a while ago and not all of them have been fully
tested.

There are a few examples below, which assume you are a knowledgeable Unix user.

## BashSeq

* nseqs.sh: Count the number of sequences in one or more fastA files.

```Bash
# 8 sequences per gene
bashseq/nseqs.sh seqs/*.aln.fco
```

## PerlSeq

* fasta2*.pl: several scripts to convert from fastA into other sequence formats.

```Bash
# Prepare a file with sequence name labels
grep '>' seqs/ND1.aln.fco | sed 's/^>//' > seqs/labels.txt
# Convert fasta to phylip sequential
perlseq/fasta2phys.pl seqs/labels.txt < seqs/ND1.aln.fco | less -S
# Convert fasta to phylip interleaved
perlseq/fasta2phyi.pl seqs/labels.txt < seqs/ND1.aln.fco | less -S
```

* format-pretty-aln.pl: Useful for quickly visualising alignments on the
terminal. Option 'co' is suitable for codon alignments.

```Bash
# view codon alignment on the terminal
perlseq/format-pretty-aln.pl co < seqs/ND1.aln.fco | less -S
```
