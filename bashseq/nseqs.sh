#! /bin/bash

# Count the number of sequences in one or more FastA files
f=`echo $1`
for f
do
grep \> $f | wc -l
echo $f
done

