#!/bin/bash
# blast_filtering.sh - separates blast output back into parts 1, 2 and 3 and selects top blast hit for each staxid
# run from project root 

# strict mode - exit on errors and pipeline failures
set -eo pipefail

# move into results/ and exit if not in root
cd results || \
{ echo "Results directory not found, please ensure you are running this script from project root"; exit 1; }

mkdir -p 5_blast_filtering

for tsv in 4_blast_outputs/*.tsv; do

    ##########
    # split main blast output into each samples' parts:
    ##########

    # extract base name
    name=$(basename "$tsv" _blast.tsv)

    echo "Splitting "$name" back into parts, sorting by staxid, adding taxonomic lineages, and manually selecting BLAST hits."

    # take unique part/query names from blast, remove duplicates, and read each one
    cut -f1 4_blast_outputs/"$name"_blast.tsv | sort -u | while read -r part_name; do

        # extract all lines with that part name/query from full blast and create 'part' blast
        grep "$part_name" 4_blast_outputs/"$name"_blast.tsv > 5_blast_filtering/"$part_name"_blast.tsv
    
    done


    ##########
    # take each part blast, retrieve top hit for each unique staxid sorted by e value
    ##########
    for part in 5_blast_filtering/"$name"*_blast.tsv; do

        # extract part base name
        part_name=$(basename "$part" _blast.tsv)

        # sort by staxid, then e value, then print line if unique staxid. this retrieves top blast hit for each staxid
        sort -k3,3 -k12,12g 5_blast_filtering/"$part_name"_blast.tsv | awk -F'\t' '!seen[$3]++' > top_hits.tsv

        # add taxonkit lineage for overview of blast
        cut -f3 top_hits.tsv | taxonkit lineage > lineages.tsv 

        # paste works as order/line count kept for both temp files
        paste top_hits.tsv lineages.tsv >  5_blast_filtering/"$part_name"_top_hit_per_staxid.tsv

    done

done

rm lineages.tsv 
rm top_hits.tsv

cd ..
