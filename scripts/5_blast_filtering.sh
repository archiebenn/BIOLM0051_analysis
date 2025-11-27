#!/bin/bash
# blast_filtering.sh - separates blast output back into parts 1, 2 and 3 and selects top blast hit for each staxid
# run from project root 

##########
# 1. setup and error handling
##########

# strict mode - exit on errors and pipeline failures
set -eo pipefail

# move into results/ and exit if not in root
cd results || \
{ echo "Results directory not found, please ensure you are running this script from project root"; exit 1; }

# create output folder
mkdir -p 5_blast_filtering

# set input folder to read from
input_dir=4_blast_outputs

# check that the input folder from previous script contains files for the loop (and silences internal errors)
ls "$input_dir"/*.tsv >/dev/null 2>&1 || \
{ echo "[ISSUE] No files found in $input_dir. Previous script may have failed. Exiting script."; exit 1; }



##########
# 2. main script loop to separate blast output back into parts, attach taxonomies, and select top hits per staxid:
##########

# loops through each blast output tsv
for tsv in "$input_dir"/*.tsv; do

    ##########
    # split main blast output into each samples' parts:
    # this is done as the parts appear to be homologous across samples, and downstream i will align on a per-part basis across samples.
    ##########

    # extract base name
    name=$(basename "$tsv" _blast.tsv)

    echo "Splitting "$name" back into parts, sorting BLAST hits, adding taxonomic names and ranks, and selecting best hit per species."

    # take unique part/query names from blast, remove duplicates, and read each one
    cut -f1 "$input_dir"/"$name"_blast.tsv | sort -u | while read -r part_name; do

        # extract all lines with that part name/query from full blast and create 'part' blast
        grep "$part_name" "$input_dir"/"$name"_blast.tsv > 5_blast_filtering/"$part_name"_blast.tsv
    
    done

    ##########
    # take each part blast, retrieve top hit for each unique staxid sorted by e value:
    ##########

    for part in 5_blast_filtering/"$name"*_blast.tsv; do

        # extract part base name
        part_name=$(basename "$part" _blast.tsv)

        # sort by e value ($12, numeric) 
        # within same e value -> by bitscore ($13, reverse numeric) 
        # within same e value and bitscore -> by length ($5)
        # awk command = only print line if unique $3/staxid value (skips duplicate staxids). 
        # this retrieves top blast hit for each staxid based on the above sorting -> results in ordered tsv of unique staxid hits 
        sort -k12,12g -k13,13gr -k5,5gr 5_blast_filtering/"$part_name"_blast.tsv | awk -F'\t' '!seen[$3]++' > top_hits.tsv

        # add taxonkit lineage for overview of blast species. -r -n -L taxonkit flags keep just name and rank of blast hit instead of whole lineage
        cut -f3 top_hits.tsv | taxonkit lineage -r -n -L > lineages.tsv 

        # paste together (as order/line count kept for both temp files)
        paste top_hits.tsv lineages.tsv > merged.tsv

        # ensure hits are kept to only species level (no higher ranks or subspecies etc.)
        awk -F'\t' '$16 == "species"' merged.tsv > filtered1.tsv

        # remove any occurences containing unknown 'environmental samples' or unidentified 'sp.' hits
        grep -v "environmental" filtered1.tsv | grep -v " sp\." > filtered2.tsv

        # collapse tsv further by species (in case of one species with > 1 staxid attached) and save to results
        awk -F'\t' '!seen[$15]++' filtered2.tsv >  5_blast_filtering/"$part_name"_filtered_hits.tsv

        # remove full per part blast to tidy results folder
        rm 5_blast_filtering/"$part_name"_blast.tsv

    done

done

rm lineages.tsv 
rm top_hits.tsv
rm filtered1.tsv
rm filtered2.tsv
rm merged.tsv

cd ..
