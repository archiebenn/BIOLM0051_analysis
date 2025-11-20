#!/bin/bash
# 10_build_tree.sh - use iqtree to build phylogenetic tree based on alignment files
# run from project root

# move into results/ 
cd results || \
{ echo "Results directory not found, please ensure you are running this script from project root"; exit 1; }

mkdir -p 10_tree_files 

for file in 9_alignment_files/*.afa; do

    # extract basename
    name=$(basename "$file" _alignment.afa)

    echo "Running IQ-TREE on "$name""

    # run iqtree 
    # -m MFP = 'model finder plus' as the selected model  
    # -B 1000 is ultra-fast bootstrap approximation with 1000 bootstrap replicates
    # -T AUTO flag will select best no. of threads to use
    iqtree3 -s "$file" -m MFP -B 1000 -bnni -T AUTO -redo

    # move all iqtree files to results folder
    mv "$file".* 10_tree_files

done

cd ..