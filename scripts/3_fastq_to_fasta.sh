#!/bin/bash
# fastq_to_fasta.sh - using seqtk for quality control with phred algorithm and to convert multi-line fastq to fasta sequence
# run from project root

# strict mode - exit on errors and pipeline failures
set -eo pipefail

# move into results/ and exit if not in root
cd results || \
{ echo "Results directory not found, please ensure you are running this script from project root"; exit 1; }

# make directories for raw FASTA and trimmed FASTA sequences
mkdir -p 3_FASTQC_reports
mkdir -p 3_FASTA_Q20
mkdir -p 3_FASTA_raw

input_directory=2_FASTQ_processed

# check that the input folder from previous script contains files for the loop
# also silences internal errors
ls "$input_directory"/*.FASTQ >/dev/null 2>&1 || \
{ echo "[ISSUE] No files found in $input_directory. Previous script may have failed."; exit 1; }


for fastq in 2_FASTQ_processed/*.FASTQ; do

    # extract base name of file
    name=$(basename "$fastq" _processed.FASTQ)

    # run fastqc for a report on the merged fastq file (reports not on github)
    fastqc "$fastq" -o 3_FASTQC_reports/

    # seqtk directly to raw fasta conversion (no trimming) and remove any spaces, then save
    seqtk seq -a "$fastq" | tr -d ' ' > "3_FASTA_raw/${name}_raw.fasta"

    # convert seqtk to mask bases to 'N' if lower than Q20 (threshold at 99%+ confidence), then convert to fasta and save
    seqtk seq -q20 -n N "$fastq" | seqtk seq -a - | tr -d ' ' > "3_FASTA_Q20/${name}_Q20.fasta"
    
done

cd ..