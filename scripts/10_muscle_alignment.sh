#!/bin/bash
# 9_muscle_alignment.sh - uses muscle to align fasta files and produce alignment files
# run from project root

##########
# 1. setup and error handling
##########

# strict mode - exit on errors and pipeline failures
set -eo pipefail

# move into results/ and exit if not in root
cd results || \
{ echo "Results directory not found, please ensure you are running this script from project root"; exit 1; }

mkdir -p 10_alignment_files
mkdir -p 10_supermatrix_files

# set input folder to read from
input_dir=9_protein_FASTA

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
    mv "$name"_alignment.afa 10_alignment_files

done



########## 
# 3. create a keep file to select species for the supermatrix 
########## 

# these were selected when first creating a supermatrix with catfasta2phylm and an error message appeared 
# this keepfile.txt keeps sequences with 2 or more occurrences across the 3 alignment files, along with the query sequences 

echo "AB201257.1_Balaenoptera_omurai            
DQ256378.1_Chelydra_serpentina            
AP006472.1_Balaena_mysticetus             
AP006471.1_Eschrichtius_robustus          
AP006468.1_Balaenoptera_acutorostrata     
JX454979.1_Lepidochelys_olivacea          
PQ997938.1_Balaenoptera_ricei             
NC_009260.1_Macrochelys_temminckii        
NC_007938.1_Balaenoptera_edeni            
NC_006926.1_Balaenoptera_bonaerensis      
NC_006931.1_Eubalaena_japonica            
AP006475.1_Caperea_marginata            
DQ095154.1_Eubalaena_glacialis            
AB201259.1_Balaenoptera_brydei           
MF409248.1_Balaenoptera_borealis       
DQ095155.1_Eubalaena_australis
sampleA
sampleB
sampleC
sampleD" > keep.txt 

# clean up spaces after name in keep.txt 
sed -i 's/ //g' keep.txt 



########## 
# 4. apply keep.txt to filter the alignment sequences 
########## 
for alignment in 10_alignment_files/*.afa; do 

    # extract basename 
    name=$(basename "$alignment" _alignment.afa) 

    # rename sampleA_part1 -> sampleA etc. for supermatrix  
    sed -i 's/_part[0-9]*//g' "$alignment"

    # apply keep using seqkit
    seqkit grep -n -f keep.txt "$alignment" > "$name"_filtered.afa 

    #

done 



########## 
# 5. create supermatrix using catfasta2phyml 
########## 
catfasta2phyml -f --concatenate part1_filtered.afa part2_filtered.afa part3_filtered.afa > supermatrix.afa 



##########
# 6. create partition text file for supermatrix
##########

# this defines where each part resides on the supermatrix 
echo "AA, part1 = 1-175
AA, part2 = 176-351
AA, part3 = 352-517" > partition.txt

mv keep.txt supermatrix.afa partition.txt 10_supermatrix_files/
rm part*_filtered.afa 

cd ..