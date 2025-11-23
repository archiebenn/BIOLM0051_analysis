#!/bin/bash
# manual_selection.sh - selecting samples to manually remove based off lineage/blast filtering
# run from project root 

# strict mode - exit on errors and pipeline failures
set -eo pipefail

# move into results/ and exit if not in root
cd results || \
{ echo "Results directory not found, please ensure you are running this script from project root"; exit 1; }

mkdir -p 6_blast_selected

# remove all of sampleD_part3 based on blast results (human contamination)
rm 5_blast_filtering/sampleD_part3*

# sampleA_part1 - removing OZ205431 and OZ071514. 
# regions significantly different to others and belong to Odontoceti (87/88% pident), where rest of hits are Mysticeti (up to 97% pident)
grep -v -E 'OZ205431|OZ071514' 5_blast_filtering/sampleA_part1_top_hit_per_staxid.tsv > 6_blast_selected/sampleA_part1_selected.tsv


# sampleA_part2 - removing OZ205431, MW645456, OZ004775, and OQ554145
# 99% pident with Eubalaena on 3 hits for this, so very likely to be this genus (right whales) = Mysticeti
# will remove any hits which are not from ingroup Mysticeti (all Odontoceti again)
grep 'Mysticeti' 5_blast_filtering/sampleA_part2_top_hit_per_staxid.tsv > 6_blast_selected/sampleA_part2_selected.tsv


# sampleA_part3 - removing anything not Mysticeti
# have decided on Mysticeti as ingroup based on observations from part1 and part2
# part3 has lower overall pidents and a mix of Mysticeti and Odontoceti (Odontoceti lower across most hits however)
grep 'Mysticeti' 5_blast_filtering/sampleA_part3_top_hit_per_staxid.tsv > 6_blast_selected/sampleA_part3_selected.tsv


# all parts of sampleB - keeping the same 
# only two unique staxids - both Monodontidae (only consists of 2 species - both hits, but all at 88-92%)
for sample in 5_blast_filtering/sampleB*_staxid.tsv; do

    # extract basename
    name=$(basename "$sample" _top_hit_per_staxid.tsv)

    cp "$sample" 6_blast_selected/"$name"_selected.tsv
    
done


# sampleC_part1 - keep all Thunnus, minus unclassified species MG204905 and PP661813
# this was a highly masked region but hit a lot of the Thunnus genus (true tuna), all at about 81% pident. 
grep 'Thunnus' 5_blast_filtering/sampleC_part1_top_hit_per_staxid.tsv | grep -v -E 'OZ205431|OZ071514'  > 6_blast_selected/sampleC_part1_selected.tsv


# sampleC_part2 - no hits from blast as very poor quality reads and mostly masked


# sampleC_part3 - keep all scombrinae 
# some 87-89%  pident reads of 400bp grouped around Thunnus and highest in tsv
# will also include some other scombrinae genera for phylogenetic tree downstream (about 6-8 non thunnini scombrinae present)
grep 'Scombrinae' 5_blast_filtering/sampleC_part3_top_hit_per_staxid.tsv > 6_blast_selected/sampleC_part3_selected.tsv


# sampleD_part1 
# 97-98% hits over 542bp for Dermochelys coriacea, so will keep all Americhelydia (10 hits)
grep 'Americhelydia' 5_blast_filtering/sampleD_part1_top_hit_per_staxid.tsv > 6_blast_selected/sampleD_part1_selected.tsv


# sampleD_part2
# another very strong 96% hit over 525bp (e value 0.0) for Dermochelys coriacea  
# Americhelydia clade consistently scored e values < 1e-135 so will keep an ingroup again
grep 'Americhelydia' 5_blast_filtering/sampleD_part2_top_hit_per_staxid.tsv > 6_blast_selected/sampleD_part2_selected.tsv

cd ..
