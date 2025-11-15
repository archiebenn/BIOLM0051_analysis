#!/bin/bash
# blast_taxonomy.sh - filters blast hits, then finds and counts taxonomic results from blast searches using taxonkit

# move into results/ (if running outside project root 'cd data/' will fail and an error message is printed)
cd results || \
{ echo "Samples directory not found, please ensure you are running this script from project root"; exit 1; }

mkdir -p 5_blast_taxonomy
pwd

for tsv in 4_blast_outputs/*.tsv; do

    # extract base name
    name=$(basename "$tsv" _Q20.fasta_blast.tsv)

    # run taxonkit lineage based on the staxids generated from blast script (in blast tsvs)
    cut -f3 4_blast_outputs/"$name"_Q20.fasta_blast.tsv | taxonkit lineage > temp.tsv

    # create a sorted/counted file for each of the species detected from blast search and taxonkit
    cut -f1,2 temp.tsv | sort | uniq -c | sort -nr > "$name"_taxonomic_counts.txt

    # move to results folder
    mv "$name"_taxonomic_counts.txt 5_blast_taxonomy

    # remove as not needed
    rm temp.tsv 
    

done

cd ..

#### TODO - get it to filter for e values and coverage etc.