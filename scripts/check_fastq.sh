#!/bin/bash
# check_fastq.sh - a quick checking script to see if they all have 4 lines 
# each should have a label, raw sequence, + sign, and quality score line
# this shell script must be run from the project root due to hardcoded paths for file moves and folder creation



# move into samples/ (if running outside project root 'cd data/' will fail and an error message is printed)
pwd
cd data/samples || \
{ echo "Samples directory not found, please ensure you are running this script from project root"; exit 1; }

for fastq in *.FASTQ; do
    lines=$(cat $fastq | wc -l)
    if [ "$lines" -ne 4 ]; then
        echo "File $fastq does not contain 4 lines"
    fi
done