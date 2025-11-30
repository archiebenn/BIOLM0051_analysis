#!/bin/bash
# fastq_to_fasta.sh - using seqtk for quality control with phred algorithm and to convert multi-line fastq to fasta sequence
# run from project root

##########
# 1. setup and error handling
##########

# strict mode - exit on errors and pipeline failures
set -eo pipefail

# move into results/ and exit if not in root
cd results || \
{ echo "Results directory not found, please ensure you are running this script from project root"; exit 1; }

# remove output folders if they exist (if re-running with existing results/)
rm -rf 3_FASTQC_reports 3_FASTA_Q20 3_FASTA_raw

# make directories for raw FASTA and trimmed FASTA sequences
mkdir -p 3_FASTQC_reports
mkdir -p 3_FASTA_Q20
mkdir -p 3_FASTA_raw

# set input folder to read from
input_dir=2_FASTQ_processed

# check that the input folder from previous script contains files for the loop (and silences internal errors)
ls "$input_dir"/*.FASTQ >/dev/null 2>&1 || \
{ echo "[ISSUE] No files found in $input_dir. Previous script may have failed. Exiting script."; exit 1; }



##########
# 2. main script loop to convert FASTQ to FASTA:
##########

# loops through each concatenated FASTQ file
for fastq in "$input_dir"/*.FASTQ; do

    # extract base name of file
    name=$(basename "$fastq" _processed.FASTQ)

    # run fastqc for a report on the merged fastq file (reports not on github)
    fastqc "$fastq" -o 3_FASTQC_reports/

    # seqtk directly to raw fasta conversion (no trimming) and remove any spaces, then save
    seqtk seq -a "$fastq" | tr -d ' ' > "3_FASTA_raw/${name}_raw.fasta"

    # convert seqtk to mask bases to 'N' if lower than Q20 (threshold at 99%+ confidence), convert to fasta, delete any spaces, and save
    seqtk seq -q20 -n N "$fastq" | seqtk seq -a - | tr -d ' ' > "3_FASTA_Q20/${name}_Q20.fasta"
    
done

cd ..