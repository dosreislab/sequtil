# SeqUtil

A set of Perl and Bash scripts to work with molecular sequences.

The scripts should work "out of the box" in any Unix system. That is, without
the need for installing any libraries or additional scripts.

These scripts were written a while ago and not all of them have been fully
tested.

Directory `seqs/` contains sequences for running the examples below.

## Examples

### BashSeq

```Bash
# nseqs.sh: Count the number of sequences in one or more fastA files.
# 8 sequences per gene
nseqs.sh *.aln.fco
```

## PerlSeq

```Bash
# format-pretty-aln.pl: Useful for quickly visualising alignments on the
# terminal. The option 'co' is suitable for codon alignments.

format-pretty-aln.pl co <ND1.aln.fco | less -S
```
