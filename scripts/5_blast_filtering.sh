#!/bin/bash
# blast_taxonomy.sh - filters blast hits, then finds and counts taxonomic results from blast searches using taxonkit

# move into results/ (if running outside project root 'cd data/' will fail and an error message is printed)
cd results || \
{ echo "Samples directory not found, please ensure you are running this script from project root"; exit 1; }

mkdir -p 5_blast_filtering
pwd

for tsv in 4_blast_outputs/*.tsv; do

    # extract base name
    name=$(basename "$tsv" _Q20.fasta_blast.tsv)

    # make sample subfolders 
    mkdir -p 5_blast_filtering/"$name"

    # split up the blast outputs back into the 3 parts, as cannot assume same sequence loci, before further analysis:
    # uses awk to take the query sequence name (in column 1/$1 of tsv) and rename a file to that name
    awk -F'\t' '{print > ($1 "_blast.tsv")}' 4_blast_outputs/"$name"_Q20.fasta_blast.tsv

    # run taxonkit lineage based on the staxids generated from blast script (in blast tsvs). this is for the 
    cut -f3 4_blast_outputs/"$name"_Q20.fasta_blast.tsv | taxonkit lineage > temp.tsv

    # create a sorted/counted file for each of the species detected from blast search and taxonkit, this is just for a guide of the top hits from blast
    cut -f1,2 temp.tsv | sort | uniq -c | sort -nr > "$name"_taxonomic_counts.txt

    # filter blast results sto retrieve top hit for each staxid occurrence. awk prints to output only if it hasn't been 'seen' already in the file, based on staxid from hits
    awk -F'\t' '!seen[$]++' 4_blast_outputs/"$name"_Q20.fasta_blast.tsv > "$name"_staxid_top_hit.txt.tsv

    # remove as not needed
    rm temp.tsv 

    # move all into individual sample folders
    mv "$name"* 5_blast_filtering/"$name"/

done

cd ..

#### TODO - get it to filter for e values and coverage etc.