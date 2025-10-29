#!/bin/bash
# concatenate_fastq.sh - this script will concatenate FASTQ sample parts into one whole FASTQ for each of the samples given

cd data/samples 
ls *.FASTQ
for i in ls *.FASTQ; do
    echo "File 1: $i"
done