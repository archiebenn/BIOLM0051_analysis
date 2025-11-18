#!/bin/bash
# 7_concatenate_fasta.sh - joins each original sample's parts to the trimmed fastas from efetch
# run from project root

# move into results/ 
cd results || \
{ echo "Results directory not found, please ensure you are running this script from project root"; exit 1; }

mkdir -p 9_alignment_files

