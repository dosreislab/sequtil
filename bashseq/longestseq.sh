#! /bin/bash

# Prints the longest sequence in a FastA file ($1)
seqlength.pl <$1 | awk '{i=$1; if($1 > i) i=$1} END {print i}'
