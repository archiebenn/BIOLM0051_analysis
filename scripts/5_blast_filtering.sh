#!/bin/bash
# blast_filtering.sh - separates blast output back into parts 1, 2 and 3.
# then for each part's blast outputs runs taxonkit for an overview, and also selects top hit per staxid for alignment downstream checks of all parts in samples

# move into results/ (if running outside project root 'cd data/' will fail and an error message is printed)
cd results || \
{ echo "Samples directory not found, please ensure you are running this script from project root"; exit 1; }

mkdir -p 5_blast_filtering

for tsv in 4_blast_outputs/*.tsv; do
    
    # 1.split main blast output into each samples' parts:
    # extract base name
    name=$(basename "$tsv" _Q20.fasta_blast.tsv)

    echo "Generating tanonomic lineage counts and sorting unique taxa from BLAST staxid for "$name""

    # awk to take the query sequence name (in column 1/$1 of tsv) and retrieve blast hits for that part
    awk -F'\t' -v out="5_blast_filtering/" '{print > (out "/" $1 "_blast.tsv")}' 4_blast_outputs/"$name"_Q20.fasta_blast.tsv

    # 2.retrieve top blast hit of each unique staxid:
    for part in 5_blast_filtering/*_blast.tsv; do

        # extract part base name
        part_name=$(basename "$part" _blast.tsv)

        # run taxonkit lineage based on the staxids generated from 'part' blast tsv for an overview
        cut -f3 5_blast_filtering/"$part_name"_blast.tsv | taxonkit lineage > temp.tsv

        # create a sorted/counted file for each of the species detected from blast search and taxonkit, this is just for a guide of the top hits from blast
        cut -f1,2 temp.tsv | sort | uniq -c | sort -nr > 5_blast_filtering/"$part_name"_taxonomic_counts.txt

        # awk to print line to output tsv if it hasn't 'seen' that staxid (in column 3/$3) before to ensure no repeated staxids (to not bloat efetch but keep phylogenetic diversity)
        awk -F'\t' '!seen[$3]++' 5_blast_filtering/"$part_name"_blast.tsv > 5_blast_filtering/"$part_name"_unique_taxa.tsv

        # remove as not needed
        rm temp.tsv 
    done

done

cd ..
