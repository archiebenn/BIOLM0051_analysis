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

# remove all of sampleD_part3 based on blast results (human contamination)
rm "$input_dir"/sampleD_part3*

# sampleA_part1 - removing OZ205431 and OZ071514. 
# regions significantly different to others and belong to Odontoceti (87/88% pident), where rest of hits are Mysticeti (up to 97% pident)
grep -v -E 'OZ205431|OZ071514' "$input_dir"/sampleA_part1_top_hit_per_staxid.tsv > 6_blast_selected/sampleA_part1_selected.tsv


# sampleA_part2 - removing OZ205431, MW645456, OZ004775, and OQ554145
# 99% pident with Eubalaena on 3 hits for this, so very likely to be this genus (right whales) = Mysticeti
# will remove any hits which are not from ingroup Mysticeti (all Odontoceti again)
grep 'Mysticeti' "$input_dir"/sampleA_part2_top_hit_per_staxid.tsv > 6_blast_selected/sampleA_part2_selected.tsv


# sampleA_part3 - removing anything not Mysticeti
# have decided on Mysticeti as ingroup based on observations from part1 and part2
# part3 has lower overall pidents and a mix of Mysticeti and Odontoceti (Odontoceti lower across most hits however)
grep 'Mysticeti' "$input_dir"/sampleA_part3_top_hit_per_staxid.tsv > 6_blast_selected/sampleA_part3_selected.tsv


# all parts of sampleB - keeping the same 
# only two unique staxids - both Monodontidae (only consists of 2 species - both hits, but all at 88-92%)
for sample in "$input_dir"/sampleB*_staxid.tsv; do

    # extract basename
    name=$(basename "$sample" _top_hit_per_staxid.tsv)

    cp "$sample" 6_blast_selected/"$name"_selected.tsv
    
done


# sampleC_part1 - keep all Thunnus, minus unclassified species MG204905 and PP661813
# this was a highly masked region but hit a lot of the Thunnus genus (true tuna), all at about 81% pident. 
grep 'Thunnus' "$input_dir"/sampleC_part1_top_hit_per_staxid.tsv | grep -v -E 'OZ205431|OZ071514'  > 6_blast_selected/sampleC_part1_selected.tsv


# sampleC_part2 - no hits from blast as very poor quality reads and mostly masked


# sampleC_part3 - keep all scombrinae 
# some 87-89%  pident reads of 400bp grouped around Thunnus and highest in tsv
# will also include some other scombrinae genera for phylogenetic tree downstream (about 6-8 non thunnini scombrinae present)
grep 'Scombrinae' "$input_dir"/sampleC_part3_top_hit_per_staxid.tsv > 6_blast_selected/sampleC_part3_selected.tsv


# sampleD_part1 
# 97-98% hits over 542bp for Dermochelys coriacea, so will keep all Americhelydia (10 hits)
grep 'Americhelydia' "$input_dir"/sampleD_part1_top_hit_per_staxid.tsv > 6_blast_selected/sampleD_part1_selected.tsv


# sampleD_part2
# another very strong 96% hit over 525bp (e value 0.0) for Dermochelys coriacea  
# Americhelydia clade consistently scored e values < 1e-135 so will keep an ingroup again
grep 'Americhelydia' "$input_dir"/sampleD_part2_top_hit_per_staxid.tsv > 6_blast_selected/sampleD_part2_selected.tsv

cd ..
