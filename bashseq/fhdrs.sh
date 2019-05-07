#! /bin/bash

# Get headers from a FastA file
grep \> $1 | sed s/\>//g
