#!/bin/bash
# fastq_to_fasta.sh - using seqtk for quality control with phred algorithm and to convert multi-line fastq to fasta sequence
# this shell script must be run from the project root due to hardcoded paths for file moves 

# move into results/ (if running outside project root 'cd results/' will fail and an error message is printed)
cd results || \
{ echo "Results directory not found, please ensure you are running this script from project root"; exit 1; }

# make directories for raw FASTA and trimmed FASTA sequences
mkdir -p FASTA_raw
mkdir -p FASTA_masked

for fastq in FASTQ_processed/*.FASTQ; do

    # extract base name of file
    name=$(basename "$fastq" _processed.FASTQ)

    # seqtk directly to raw fasta conversion (no trimming) and remove any spaces, then save
    seqtk seq -a "$fastq" | tr -d ' ' > "FASTA_raw/${name}_raw.fasta"

    # convert seqtk to mask bases to 'N' if lower than Q20 (threshold at 99%+ confidence), then convert to fasta and save
    seqtk seq -q20 -n N "$fastq" | seqtk seq -a - | tr -d ' ' > "FASTA_masked/${name}_Q20.fasta"

done
echo
echo "FASTA conversion completed. Find raw FASTA outputs in results/FASTA_raw and masked outputs in results/FASTA_masked"
