#!/bin/bash
# check_fastq.sh - a checking script to see each fastq's main structure
# run from project root

# strict mode - exit on errors and pipeline failures
set -eo pipefail

# move into samples/ and exit if not in root
cd data/samples || \
{ echo "Samples directory not found, please ensure you are running this script from project root"; exit 1; }

mkdir -p ../../results
mkdir -p ../../results/1_FASTQ_check



##########
# main script loop to run FASTQ header check:
##########

# loop through FASTQs
for fastq in *.FASTQ; do  

    # identifier for readability in text file
    echo "$fastq file format:" >> 1_FASTQ_format_check.txt         

    # cut out first 15 characters of every line, along with line numbering and -ba to catch all lines in the FASTQ file:
    cut -c-15 "$fastq" | nl -ba  >> 1_FASTQ_format_check.txt 

    # space for readability         
    echo >> 1_FASTQ_format_check.txt   
        
done

mv 1_FASTQ_format_check.txt ../../results/1_FASTQ_check                           

cd ../../