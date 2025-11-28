#!/bin/bash
# 11_muscle_alignment.sh - uses muscle to align fasta files and produce alignment files
# run from project root

##########
# 1. setup and error handling
##########

# strict mode - exit on errors and pipeline failures
set -eo pipefail

# move into results/ and exit if not in root
cd results || \
{ echo "Results directory not found, please ensure you are running this script from project root"; exit 1; }

# remove output folders if they exist (if re-running with existing results/))
rm -rf 11_alignment_files 11_supermatrix_files

# make output folders
mkdir -p 11_alignment_files
mkdir -p 11_supermatrix_files

# set input folder to read from
input_dir=10_protein_FASTA

# check that the input folder from previous script contains files for the loop (and silences internal errors)
ls "$input_dir"/*.fasta >/dev/null 2>&1 || \
{ echo "[ISSUE] No files found in $input_dir. Previous script may have failed. Exiting script."; exit 1; }



##########
# 2. main script loop to align protein fasta sequences:
##########

for fasta in "$input_dir"/*.fasta; do

    # extract basename
    name=$(basename "$fasta" _complete.fasta_prot.fasta)

    echo "Aligning "$name" sequences with MUSCLE"

    # run alignment with muscle
    muscle -align "$fasta" -output "$name"_alignment.afa 

     # can view alignment using aliview - un-hash to view on each loop
     # aliview "$name"_alignment.afa

    # move alignment 
    mv "$name"_alignment.afa 11_alignment_files

done



##################
# DO A TRIMAL THING HERE





########## 
# 3. apply keep.txt to filter the alignment sequences 
########## 
for alignment in 11_alignment_files/*.afa; do 

    # extract basename 
    name=$(basename "$alignment" _alignment.afa) 

    # sed to rename sampleA_part1 -> sampleA etc. for supermatrix (treats same headers as one sequence in supermatrix)
    sed -i 's/_part[0-9]*//g' "$alignment"  > "$name"_filtered.afa 

done 



########## 
# 4. create supermatrix using catfasta2phyml 
########## 
catfasta2phyml -f --concatenate part1_filtered.afa part2_filtered.afa part3_filtered.afa > supermatrix.afa 



##########
# 6. create partition text file for supermatrix
##########

# this defines where each part resides on the supermatrix 
echo "AA, part1 = 1-175
AA, part2 = 176-351
AA, part3 = 352-517" > partition.txt

mv supermatrix.afa partition.txt 11_supermatrix_files/
rm part*_filtered.afa 

cd ..