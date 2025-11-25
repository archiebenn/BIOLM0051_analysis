#!/bin/bash
# concatenate_fasta.sh - joins each original sample's parts to the trimmed fastas from efetch
# run from project root

##########
# 1. setup and error handling
##########

# strict mode - exit on errors and pipeline failures
set -eo pipefail

# move into results/ and exit if not in root
cd results || \
{ echo "Results directory not found, please ensure you are running this script from project root"; exit 1; }

mkdir -p 8_complete_FASTA

# set input folders to read from
input_dir1=3_FASTA_Q20
input_dir2=5_blast_filtering
input_dir3=7_efetch_FASTA

# check that the input folders from previous scripts contain files for the loops (and silences internal errors)
ls "$input_dir1"/*.fasta >/dev/null 2>&1 || \
{ echo "[ISSUE] No files found in $input_dir1. A previous script may have failed. Exiting script."; exit 1; }

ls "$input_dir2"/*.tsv >/dev/null 2>&1 || \
{ echo "[ISSUE] No files found in $input_dir2. A previous script may have failed. Exiting script."; exit 1; }

ls "$input_dir3"/*.fasta >/dev/null 2>&1 || \
{ echo "[ISSUE] No files found in $input_dir3. A previous script may have failed. Exiting script."; exit 1; }



###########
# 2. first main script to loop over SampleA-D and extract header names from previous blast on unknown sequence:
###########

# sequences from same blast run
for sample in "$input_dir1"/*.fasta; do

    #extract sample name
    name=$(basename "$sample" _Q20.fasta)

    # extract header names of original Q20 fasta file (for each part)
    for part in "$input_dir2"/"$name"*_blast.tsv; do

        # extract part base name
        part_name=$(basename "$part" _blast.tsv)

        ##########
        # change efetch fasta header names to keep genus and species attached downstream
        ##########

        # copy efetch fastas for header editing and to keep original efetch fastas intact
        cp "$input_dir3"/"$part_name".fasta  8_complete_FASTA/"$part_name"_complete.fasta

        # select first 3 space separated fields ('accession:region, genus, species in header) and save to temp
        awk '/^>/ {print $1, $2, $3; next} {print}' 8_complete_FASTA/"$part_name"_complete.fasta > awk_temp.fasta  

        # overwrite with awk file to allow in-place edit
        mv awk_temp.fasta 8_complete_FASTA/"$part_name"_complete.fasta

        # remove all between : and first space (remove ':region')
        sed -i 's/:[^ ]* /_/g' 8_complete_FASTA/"$part_name"_complete.fasta

        # substitute all spaces to underscrores in header 
        sed -i '/^>/s/ /_/g' 8_complete_FASTA/"$part_name"_complete.fasta

        ##########
        # concatenate edited efetch fastas and original part fastas
        ##########

        # run seqkit grep to match 'part' sequence in original masked fasta and save matched sequence to og_temp
        seqkit grep -p "$part_name" "$input_dir1"/"$name"_Q20.fasta > og_temp.fasta

        echo "Concatenating original file part with efetch FASTAs for "$part_name""

        # concatenate header-edited efetch fastas and original fasta file parts (which were used as BLAST queries)
        cat og_temp.fasta 8_complete_FASTA/"$part_name"_complete.fasta > 8_complete_FASTA/"$part_name"_complete.temp
        mv 8_complete_FASTA/"$part_name"_complete.temp 8_complete_FASTA/"$part_name"_complete.fasta

    done

    rm og_temp.fasta

done

###########
# 3. second main script to loop over parts 1-3 and  and merge all part files together to end with part1_complete.fasta etc.
###########

# sequences just generate
for part in 8_complete_FASTA/*.fasta; do

    # extract basename
    part = $(basename sample*_ "$part" _complete.fasta)

    echo "$part"

done



cd ..