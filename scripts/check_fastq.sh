#!/bin/bash
# check_fastq.sh - a checking script to see if each sample fastq follows fastq format
# each should have a label, raw sequence, + sign, and quality score line
# this shell script must be run from the project root due to hardcoded paths for file moves and folder creation


# move into samples/ (if running outside project root 'cd data/' will fail and an error message is printed)
pwd
cd data/samples || \
{ echo "Samples directory not found, please ensure you are running this script from project root"; exit 1; }


for fastq in *.FASTQ; do                                                             
    echo "$fastq file format:" >> fastq_format_check.txt           # for readability
    cut -c-15 "$fastq" | nl -ba  >> fastq_format_check.txt         # cuts out first 15 characters of every line, along with line numbering and -ba to catch all lines in file
    echo >> fastq_format_check.txt                                 # space for readability   
done

mv fastq_format_check.txt ../../results/                           # move file to results folder
echo
echo "FastQ check complete. Find output in results/"