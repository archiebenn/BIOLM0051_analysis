#!/bin/bash
# 9_muscle_alignment.sh - uses muscle to align fasta files and produce alignment files
# run from project root

# strict mode - exit on errors and pipeline failures
set -eo pipefail

# move into results/ and exit if not in root
cd results || \
{ echo "Results directory not found, please ensure you are running this script from project root"; exit 1; }

mkdir -p 10_alignment_files

for fasta in 9_protein_FASTA/*.fasta; do

    # extract basename
    name=$(basename "$fasta" _complete.fasta_prot.fasta)

    echo "Aligning sequences in "$name" with MUSCLE"

    # run alignment with muscle
    muscle -align "$fasta" -output "$name"_alignment.afa 

     # can view alignment using aliview - un-hash to view on each loop
     # aliview "$name"_alignment.afa

    # move alignment 
    mv "$name"_alignment.afa 10_alignment_files

done

cd ..