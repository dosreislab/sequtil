#! /bin/bash
# by Asif
sed -n "$1p" $2.index | while read start end header
do
	len=`echo "$end-$start" | bc`
	dd if=$2 skip=$start bs=1 count=$len status=noxfer of=tmp.out 2>/dev/null
	cat tmp.out
done
rm tmp.out


