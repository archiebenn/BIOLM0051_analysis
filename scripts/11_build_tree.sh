#!/bin/bash
# 10_build_tree.sh - use iqtree to build phylogenetic tree based on alignment files
# run from project root

##########
# 1. setup and error handling
##########

# move into results/ and exit if not in root
cd results || \
{ echo "Results directory not found, please ensure you are running this script from project root"; exit 1; }

mkdir -p 11_tree_files 

# set input folder to read from
input_dir=10_alignment_files

# check that the input folder from previous script contains files for the loop (and silences internal errors)
ls "$input_dir"/*.afa >/dev/null 2>&1 || \
{ echo "[ISSUE] No files found in $input_dir. Previous script may have failed. Exiting script."; exit 1; }



##########
# 2. main script loop for building phylogenetic part trees using iqtree:
##########

for file in "$input_dir"/*.afa; do

    # extract basename
    name=$(basename "$file" _alignment.afa)

    echo "Running IQ-TREE on "$name""

    # run iqtree 
    # -m MFP = 'model finder plus' as the selected model  
    # -B 1000 is ultra-fast bootstrap approximation with 1000 bootstrap replicates
    # -T AUTO flag will select best no. of threads to use
    iqtree3 -s "$file" -m MFP -B 1000 -bnni -T AUTO -redo

    # move all iqtree files to results folder
    mv "$file".* 11_tree_files

done



##########
# 3. build supermatrix tree with all samples  
##########

iqtree3 -s

cd ..