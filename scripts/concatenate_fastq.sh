#!/bin/bash
# concatenate_fastq.sh - this script will concatenate FASTQ sample parts into one whole FASTQ for each of the samples given

cd data/samples 

for letter in {A..D}; do
    x=$letter
    echo "File $x consists of:"
    ls sample$x*
done

