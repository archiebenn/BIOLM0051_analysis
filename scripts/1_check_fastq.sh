#!/bin/bash
# check_fastq.sh - a checking script to see each fastq's main structure
# run from project root

##########
# 1. setup  and error handling
##########

# strict mode - exit on errors and pipeline failures
set -eo pipefail

# move into samples/ and exit if not in root
cd data/ || \
{ echo "Data directory not found, please ensure you are running this script from project root"; exit 1; }

# remove output folder if it exists (if re-running with existing results/)
rm -rf samples ../results/1_checked_FASTQ

# make output folders
mkdir -p ../results
mkdir -p samples
mkdir -p ../results/1_checked_FASTQ

# check that the input folder from previous script contains files for the loop (and silences internal errors)
ls *.zip >/dev/null 2>&1 || \
{ echo "[ISSUE] No zip file found in data/. Please ensure zipped data are present in this directory to begin analysis. Exiting script."; exit 1; }



##########
# 2. extracting samples and moving to samples folder
##########

unzip -q samples.zip -d samples/


##########
# 3. main script loop to run FASTQ header check:
##########
# move into directpry with .FASTQ files
cd samples/samples/

# loop through FASTQs
for fastq in *.FASTQ; do  

    # identifier for readability in text file
    echo "$fastq file format:" >> 1_FASTQ_format_check.txt         

    # cut out first 15 characters of every line, along with line numbering and -ba to catch all lines in the FASTQ file:
    cut -c-15 "$fastq" | nl -ba  >> 1_FASTQ_format_check.txt 

    # space for readability         
    echo >> 1_FASTQ_format_check.txt   
        
done

# move check file out to results folder
mv 1_FASTQ_format_check.txt ../../../results/1_FASTQ_check                           

cd ../../../