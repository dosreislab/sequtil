#! /bin/bash

# Sort disordered sequences from an alignment program so that
# the alignment (in FastA format) is printed out as in the
# original input files. Modified from Asif.

# Usage: reorderseqs.sh UNORDERED ORDERED
unordered=$1
ordered=$2

grep ">" $unordered | cat -n > tmp.$$.seq.order
grep -o "^>.*$" $ordered |
while read id
do
    grep "${id}" tmp.$$.seq.order
done | awk '{print $1}' > ${f}.$$.tmp.order
rm -f tmp.$$.seq.order
extractseqs.pl ${f}.$$.tmp.order < $unordered #> $unordered.ordered
rm -f $f.$$.tmp.order
