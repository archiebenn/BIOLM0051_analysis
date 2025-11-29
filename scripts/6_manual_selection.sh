#!/bin/bash
# manual_selection.sh - selecting samples to 'manually' remove based off lineage/blast filtering
# ending up with tsv including top 5 selected blast hits for each part
# run from project root 

##########
# 1. setup and error handling
##########

# strict mode - exit on errors and pipeline failures
set -eo pipefail

# move into results/ and exit if not in root
cd results || \
{ echo "Results directory not found, please ensure you are running this script from project root"; exit 1; }

# remove output folder if it exists (if re-running with existing results/))
rm -rf 6_blast_selected

# create output folder
mkdir -p 6_blast_selected


# set input folder to read from
input_dir=5_blast_filtering

# check that the input folder from previous script contains files (and silences internal errors)
ls "$input_dir"/*.tsv >/dev/null 2>&1 || \
{ echo "[ISSUE] No files found in $input_dir. Previous script may have failed. Exiting script."; exit 1; }



##########
# 2. manual selection of blast hits to keep while minimising bias:
##########

# remove any multi-species hits which would be in the top 10 (below) tsv as they do not correspond to a clean reference genome
grep -v 'Scomberomorus munroi x Scomberomorus semifasciatus' 5_blast_filtering/sampleC_part3_filtered_hits.tsv > temp
mv temp 5_blast_filtering/sampleC_part3_filtered_hits.tsv

grep -v 'Eretmochelys imbricata x Chelonia mydas' 5_blast_filtering/sampleD_part1_filtered_hits.tsv > temp
mv temp 5_blast_filtering/sampleD_part1_filtered_hits.tsv


# reduce filtered tsv size to a maximum length of 5 hits
# these are already sorted by e value -> bitscore -> length so these are the 10 most biologically relevant BLAST hits
for tsv in "$input_dir"/*.tsv; do

    # extract basename 
    part=$(basename "$tsv" _filtered_hits.tsv)

    # take top 4 of each part blast - selected based on 15-20 phylogenetically diverse references in final tree
    head -n 4 "$input_dir"/"$part"_filtered_hits.tsv > 6_blast_selected/"$part"_selected.tsv

done

# remove sampleD_part3. this is only hitting homo sapiens from blast, so is likely contamination.
# emptying instead of deleting as deleting the file causes downstream loop issues
rm 6_blast_selected/sampleD_part3_selected.tsv

cd ..
