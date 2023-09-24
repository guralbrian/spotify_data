#!/bin/bash

# Temp, empty file to store results
> results.txt

# Loop through each command and 
# Record number of lines in its man page
# get manual, pipe into word count by lines, pipe into awk to format the output as command + lines
for cmd in man ls find; do
  man $cmd | wc -l | awk -v cmd=$cmd '{print cmd "," $1}' >> results.txt
done

# Part to sort the contents of the temp results.txt by number of lines
# Prints the results too, with awk to do the formatting
sort -t, -k2,2 -g -r results.txt | awk -F, '{print $1 " has " $2 " lines in its man page"}'

# Remove the temporary results file
rm results.txt
