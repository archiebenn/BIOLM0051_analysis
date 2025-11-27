#!/bin/bash
# manual_selection.sh - selecting samples to manually remove based off lineage/blast filtering
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
mkdir -p 6_blast_selected

# set input folder to read from
input_dir=5_blast_filtering

# check that the input folder from previous script contains files (and silences internal errors)
ls "$input_dir"/*.tsv >/dev/null 2>&1 || \
{ echo "[ISSUE] No files found in $input_dir. Previous script may have failed. Exiting script."; exit 1; }



##########
# 2. manual selection of blast hits to keep:  
##########



# all parts of sampleB - keeping the same 
# only two unique staxids - both Monodontidae (only consists of 2 species - both hits, but all at 88-92%)
for sample in "$input_dir"/sampleB*_filtered_hits.tsv; do

    # extract basename
    name=$(basename "$sample" _filtered_hits.tsv)

    cp "$sample" 6_blast_selected/"$name"_selected.tsv
    
done




cd ..
