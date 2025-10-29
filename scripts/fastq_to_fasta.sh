#!/bin/bash
# fastq_to_fasta.sh - use 
# this shell script must be run from the project root due to hardcoded paths for file moves 


# move into results/ (if running outside project root 'cd results/' will fail and an error message is printed)
cd results || \                                                
{ echo "Results directory not found, please ensure you are running this script from project root"; exit 1; }

mkdir -p processed_FASTA

for fastq in processed_FASTQ; do
    sed -i '/^@/d' 
    sed -i '/^+/d'