#!/bin/bash
# 10_build_tree.sh - use iqtree to build phylogenetic tree based on alignment files
# run from project root

##########
# 1. setup and error handling
##########

# move into results/ and exit if not in root
cd results || \
{ echo "Results directory not found, please ensure you are running this script from project root"; exit 1; }

# remove output folders if they exists (if re-running with existing results/))
rm -rf 12_tree_files 

# make output folder
mkdir -p 12_tree_files 
mkdir -p 12_tree_outputs
mkdir -p 12_tree_pdfs

# set input folder to read from
input_dir=11_alignment_files

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
    mv "$file".* 12_tree_outputs

done



##########
# 3. build supermatrix tree with all samples  
##########
# reads supermatrix and off partition file to separate the parts (for potentially different mutation rates per part etc.)
iqtree3 -s 10_supermatrix_files/supermatrix.afa -p 10_supermatrix_files/partition.txt -m MFP+MERGE -B 1000 --alrt 1000 -T AUTO -redo

# move supermatrix files to tree file folder
mv 10_supermatrix_files/partition.txt.* 12_tree_outputs/

# move all .treefile nexus outputs into the tree_files folder
cp 12_tree_outputs/*.treefile 12_tree_files/

cd ..