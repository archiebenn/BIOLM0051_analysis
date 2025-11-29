#!/bin/bash
# concatenate_fasta.sh - joins each original sample's parts to the respective trimmed fastas from efetch and attaches the full outgroup mitochondrial genome
# run from project root

##########
# 1. setup and error handling
##########

# strict mode - exit on errors and pipeline failures
#set -eo pipefail

# move into results/ and exit if not in root
cd results || \
{ echo "Results directory not found, please ensure you are running this script from project root"; exit 1; }

# remove output folder if it exists (if re-running with existing results/))
rm -rf 9_complete_FASTA

# make output folder
mkdir -p 9_complete_FASTA

# set input folders to read from
input_dir1=3_FASTA_Q20
input_dir2=5_blast_filtering
input_dir3=7_efetch_FASTA
input_dir4=8_outgroup_FASTA

# check that the input folders from previous scripts contain files for the loops (and silences internal errors)
ls "$input_dir1"/*.fasta >/dev/null 2>&1 || \
{ echo "[ISSUE] No files found in $input_dir1. A previous script may have failed. Exiting script."; exit 1; }

ls "$input_dir2"/*.tsv >/dev/null 2>&1 || \
{ echo "[ISSUE] No files found in $input_dir2. A previous script may have failed. Exiting script."; exit 1; }

ls "$input_dir3"/*.fasta >/dev/null 2>&1 || \
{ echo "[ISSUE] No files found in $input_dir3. A previous script may have failed. Exiting script."; exit 1; }

ls "$input_dir4"/*.fasta >/dev/null 2>&1 || \
{ echo "[ISSUE] No files found in $input_dir4. A previous script may have failed. Exiting script."; exit 1; }



###########
# 2. main script to loop over SampleA-D and extract header names from previous blast on unknown sequence:
###########

# sequences from same blast run
for sample in "$input_dir1"/*.fasta; do

    #extract sample name
    name=$(basename "$sample" _Q20.fasta)

    # extract header names of original Q20 fasta file (for each part)
    for tsv in "$input_dir2"/"$name"*_hits.tsv; do

        # extract part base name
        part_name=$(basename "$tsv" _filtered_hits.tsv)

        # if part file does not exist in 7_efetch_FASTA, continue 
        # added as sampleD_part3 has been deleted
        [[ ! -f "$input_dir3"/"$part_name".fasta ]] && continue

        ##########
        # change efetch fasta header names to just keep the genus and species 
        ##########

        # copy efetch fastas for header editing and to keep original efetch fastas intact
        cp "$input_dir3"/"$part_name".fasta  9_complete_FASTA/"$part_name"_complete.fasta

        # select 2nd and 3rd space separated fields (genus and species in header), put undersocre in between genus and species, then save to temp
        awk '/^>/ {print ">" $2 "_" $3; next} {print}' 9_complete_FASTA/"$part_name"_complete.fasta > awk_temp.fasta  

        # overwrite with awk file to allow in-place edit
        mv awk_temp.fasta 9_complete_FASTA/"$part_name"_complete.fasta

        ##########
        # concatenate edited efetch fastas and original part fastas
        ##########

        # run seqkit grep to match 'part' sequence in original masked fasta and save matched sequence to og_temp
        seqkit grep -p "$part_name" "$input_dir1"/"$name"_Q20.fasta > og_temp.fasta

        echo "Concatenating original file part with efetch FASTAs for "$part_name""

        # concatenate header-edited efetch fastas and original fasta file parts (which were used as BLAST queries)
        cat og_temp.fasta 9_complete_FASTA/"$part_name"_complete.fasta > 9_complete_FASTA/"$part_name"_complete.temp
        mv 9_complete_FASTA/"$part_name"_complete.temp 9_complete_FASTA/"$part_name"_complete.fasta

    done

    rm og_temp.fasta

done

echo "DONE"



###########
# 3. concatenate file parts back together and attach outgroup mitochondrial genome fastas
###########

for number in {1..3}; do

    # concatenate every fasta file per part into one main fasta part file
    cat 9_complete_FASTA/*part"$number"_complete.fasta > part"$number"_complete.fasta

    # only attach outgroup fasta files to part1 and part2. 
    # this is following alignments where part3 did not align at all with the outgroups which broke the global alignment using muscle5, so leaving part3 outgroups out
    if [[ "$number" -lt 3 ]]; then 

        # header edit as in loop above, applied to outgroup full mitochondria genome and concatenated to the main fasta part file
        awk '/^>/ {print ">" $2 "_" $3; next} {print}' "$input_dir4"/*.fasta >>  part"$number"_complete.fasta
    fi

done

# empty directory
rm 9_complete_FASTA/*

# move part files back into results folder
mv part1_complete.fasta 9_complete_FASTA/
mv part2_complete.fasta 9_complete_FASTA/
mv part3_complete.fasta 9_complete_FASTA/


cd ..