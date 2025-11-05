#!/bin/bash
# blast_taxonomy.sh - checks taxonomic results from blast searches

# move into results/ (if running outside project root 'cd data/' will fail and an error message is printed)
cd results || \
{ echo "Samples directory not found, please ensure you are running this script from project root"; exit 1; }

mkdir -p 5_blast_taxonomies
pwd

for tsv in 4_blast_outputs/*.tsv; do

    # extract base name
    name=$(basename "$tsv" _Q20.fasta_blast.tsv)

    # run taxonkit lineage based on the staxids generated from blast script (in blast tsvs)
    cut -f3 4_blast_outputs/"$name"_Q20.fasta_blast.tsv | taxonkit lineage > "$name"_blast_lineage.tsv

    # append this lineage tsv to the original blast tsv

    # move to results folder
    mv "$name"_blast_lineage.tsv 5_blast_taxonomies

done