#! /bin/bash
# by Asif
# 1. Get byte offsets of the sequence headers 
# i.e. where the sequence starts (they are prefixed with '>')
grep -b '>' $1 > tmp.file.headers.with.offset

# 2. Extract just the byte offset
cut -f1 -d ':' tmp.file.headers.with.offset > tmp.file.offset.start

# 3. We want start and end of sequence
# a) Copy the start offsets but skip the first line.
sed '1d' tmp.file.offset.start > tmp.file.offset.end

# b) Add the end offset for the last sequence (which is just the file size)
wc -c $1 | cut -f1 -d ' ' >> tmp.file.offset.end

# 4. Extract just the header lines for the index
cut -f2- -d ':' tmp.file.headers.with.offset > tmp.file.headers

# 5. Paste the start_offset, end_offset and header files together
paste tmp.file.offset.start tmp.file.offset.end tmp.file.headers > $1.index

# 6. Clean up
rm -f tmp.file.headers.with.offset tmp.file.offset.start tmp.file.offset.end tmp.file.headers

