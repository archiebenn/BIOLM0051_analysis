#!/bin/bash
# check_fastq.sh - a checking script to see if each sample fastq follows fastq format
# this shell script must be run from the project root due to hardcoded paths for file moves and folder creation

# move into samples/ (if running outside project root 'cd data/' will fail and an error message is printed)
cd data/samples || \
{ echo "Samples directory not found, please ensure you are running this script from project root"; exit 1; }

# for loop to catch every FASTQ file
for fastq in *.FASTQ; do  

    # identifier for readability in text file
    echo "$fastq file format:" >> fastq_format_check.txt         

    # cut out first 15 characters of every line, along with line numbering and -ba to catch all lines in the FASTQ file:
    cut -c-15 "$fastq" | nl -ba  >> fastq_format_check.txt 

    # space for readability         
    echo >> fastq_format_check.txt                                   
done

# move file to results folder:
mv fastq_format_check.txt ../../results/                           
echo
echo "FastQ check complete. Find output in results/"