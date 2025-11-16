#!/bin/bash
# blast_taxonomy.sh - filters blast hits, then finds and counts taxonomic results from blast searches using taxonkit
# also separates raw blast hits back into the 3 separate parts before retrieving unique taxa from staxid along with accession numbers

# move into results/ (if running outside project root 'cd data/' will fail and an error message is printed)
cd results || \
{ echo "Samples directory not found, please ensure you are running this script from project root"; exit 1; }

mkdir -p 5_blast_filtering


for tsv in 4_blast_outputs/*.tsv; do

    # extract base name
    name=$(basename "$tsv" _Q20.fasta_blast.tsv)

    # make sample subfolders 
    mkdir -p 5_blast_filtering/"$name"

    # split up the blast outputs back into the 3 parts, as cannot assume same sequence loci, before further analysis:
    # uses awk to take the query sequence name (in column 1/$1 of tsv) and rename a file to that name, output to sample subfolder
    awk -F'\t' -v out="5_blast_filtering/$name" '{print > (out "/" $1 "_blast.tsv")}' 4_blast_outputs/"$name"_Q20.fasta_blast.tsv

    # for each part of each sample, sort the top blast hit for each staxid, in order to have a diverse set of accessions across taxa
    for part in 5_blast_filtering/"$name"/*_blast.tsv; do

        # extract part base name
        part_name=$(basename "$part" _blast.tsv)

        # awk to print line to output tsv if it hasn't 'seen' that staxid (in column 3/$3) before to ensure no repeated staxids (to not bloat during alignment)
        awk -F'\t' '!seen[$3]++' 5_blast_filtering/"$name"/"$part_name"_blast.tsv > 5_blast_filtering/"$name"/"$part_name"_unique_taxa.tsv

        # run taxonkit lineage based on the staxids generated from blast script (in blast tsvs). this is for the 
        cut -f3 5_blast_filtering/"$name"/"$part_name"_unique_taxa.tsv | taxonkit lineage > temp.tsv

        # create a sorted/counted file for each of the species detected from blast search and taxonkit, this is just for a guide of the top hits from blast
        cut -f1,2 temp.tsv | sort | uniq -c | sort -nr > "$part_name"_taxonomic_counts.txt

        # remove as not needed
        rm temp.tsv 
    done

done

cd ..

#### TODO - get it to filter for e values and coverage etc.