#! /bin/bash
# by Asif.
# TODO: check that index file exists
grep "$1" $2.index | while read start end header
do 
    len=`echo "$end-$start" | bc`
    dd if=$2 skip=$start bs=1 count=$len status=noxfer of=tmp.out 2>/dev/null
    cat tmp.out # Because dd's oflag=append doesn't work on OSX! :(
done
rm -f tmp.out

