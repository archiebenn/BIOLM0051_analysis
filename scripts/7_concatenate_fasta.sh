#!/bin/bash
# 7_concatenate_fasta.sh - joins each original sample's parts to the trimmed fastas from efetch
# run from project root

# move into results/ 
cd results || \
{ echo "Results directory not found, please ensure you are running this script from project root"; exit 1; }

mkdir -p 7_complete_FASTA

###########
# 1. loop over SampleA-D, and exact header names from previous blast on unknown sequence
###########

# sequences from same blast run
for sample in 3_FASTA_Q20/*.fasta; do

    #extract sample name
    name=$(basename "$sample" _Q20.fasta)

    # exact names extracted from blast run of each part
    for part in 5_blast_filtering/"$name"*_blast.tsv; do

        # extract part base name
        part_name=$(basename "$part" _blast.tsv)

        # run seqkit grep to match 'part' sequence
        seqkit grep -p "$part_name" 3_FASTA_Q20/"$name"_Q20.fasta > temp.fasta

        echo "Concatenating original file part with efetch FASTAs for "$part_name""

        # concatenate original sequence part to efetch
        cat temp.fasta 6_efetch_FASTA/"$part_name".fasta > 7_complete_FASTA/"$part_name"_complete.fasta

    done

    rm temp.fasta

done

echo "Script 7 - FASTA concatenation - complete: Concatenated FASTA can be found in results/7_complete_FASTA"
echo

cd ..