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
rm -rf 12_tree_files 12_tree_outputs

# make output folder
mkdir -p 12_tree_files 
mkdir -p 12_tree_outputs

# set input folder to read from
input_dir=11_alignment_files
input_dir2=11_supermatrix_files

# check that the input folders from previous scripts contain files for the loops (and silences internal errors)
ls "$input_dir"/*.afa >/dev/null 2>&1 || \
{ echo "[ISSUE] No files found in $input_dir. Previous script may have failed. Exiting script."; exit 1; }

ls "$input_dir2"/*.afa >/dev/null 2>&1 || \
{ echo "[ISSUE] No files found in $input_dir2. Previous script may have failed. Exiting script."; exit 1; }



##########
# 2. build supermatrix tree with all samples  
##########

# reads supermatrix and off partition file to separate the parts (for potentially different mutation rates per part etc.)
# -m MFP+MERGE is used to find the best model and carry out partition merging using the supermatrix alignment and partition file
# -B 1000 carries out 1000 ultra-fast bootstrap replicates to give confidence on braches
# -bnni gives extra optimisation for the bootstraps
# -T auto selects the correct number of cores to use for this tree build
iqtree3 -s 11_supermatrix_files/supermatrix.afa -p 11_supermatrix_files/partition.txt -m MFP+MERGE -B 1000 -bnni -T AUTO -redo

# move supermatrix files to tree file folder
mv 11_supermatrix_files/partition.txt.* 12_tree_outputs/

# move .treefile nexus outputs into the tree_files folder
cp 12_tree_outputs/*.treefile 12_tree_files/

cd ..