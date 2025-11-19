#!/bin/bash
# 7_concatenate_fasta.sh - joins each original sample's parts to the trimmed fastas from efetch
# run from project root

# move into results/ 
cd results || \
{ echo "Results directory not found, please ensure you are running this script from project root"; exit 1; }

mkdir -p 7_complete_FASTA

###########
# loop over SampleA-D, and extract header names from previous blast on unknown sequence
###########

# sequences from same blast run
for sample in 3_FASTA_Q20/*.fasta; do

    #extract sample name
    name=$(basename "$sample" _Q20.fasta)

    # extract header names of original Q20 fasta file (for each part)
    for part in 5_blast_filtering/"$name"*_blast.tsv; do

        # extract part base name
        part_name=$(basename "$part" _blast.tsv)

        ##########
        # change efetch fasta header names to keep genus and species attached downstream
        ##########

        # copy efetch fastas for header editing and to keep original efetch fastas intact
        cp 6_efetch_FASTA/"$part_name".fasta  7_complete_FASTA/"$part_name"_complete.fasta

        # select first 3 space separated fields (accession:region, genus, species in header) 
        awk '/^>/ {print $1, $2, $3; next} {print}' 7_complete_FASTA/"$part_name"_complete.fasta > awk_temp.fasta  

        # overwrite with awk file to allow in-place edit
        mv awk_temp.fasta 7_complete_FASTA/"$part_name"_complete.fasta

        # remove all between : and first space (remove :region)
        sed -i 's/:[^ ]* /_/g' 7_complete_FASTA/"$part_name"_complete.fasta

        # substitute all spaces to underscrores in header 
        sed -i '/^>/s/ /_/g' 7_complete_FASTA/"$part_name"_complete.fasta

        ##########
        # concatenate edited efetch fastas and original part fastas
        ##########

        # run seqkit grep to match 'part' sequence in original masked fasta and save matched sequence to og_temp
        seqkit grep -p "$part_name" 3_FASTA_Q20/"$name"_Q20.fasta > og_temp.fasta

        echo "Concatenating original file part with efetch FASTAs for "$part_name""

        # concatenate header-edited efetch fastas and original fasta file parts (which were used in BLAST)
        cat og_temp.fasta 7_complete_FASTA/"$part_name"_complete.fasta > 7_complete_FASTA/"$part_name"_complete.temp
        mv 7_complete_FASTA/"$part_name"_complete.temp 7_complete_FASTA/"$part_name"_complete.fasta

    done

    rm og_temp.fasta

done

echo "Script 7 - FASTA concatenation - complete: Concatenated FASTA can be found in results/7_complete_FASTA"
echo

cd ..