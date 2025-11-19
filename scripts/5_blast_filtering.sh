#!/bin/bash
# blast_filtering.sh - separates blast output back into parts 1, 2 and 3 and selects top blast hit for each staxid
# includes manual filtering at end
# run from project root 

# move into results/ 
cd results || \
{ echo "Results directory not found, please ensure you are running this script from project root"; exit 1; }

mkdir -p 5_blast_filtering
mkdir -p 5_blast_selected

for tsv in 4_blast_outputs/*.tsv; do

    ##########
    # 1. split main blast output into each samples' parts:
    ##########

    # extract base name
    name=$(basename "$tsv" _blast.tsv)

    echo "Splitting "$name" back into parts, sorting by staxid, adding taxonomic lineages, and manually selecting BLAST hits."

    # take unique part/query names from blast, remove duplicates, and read each one
    cut -f1 4_blast_outputs/"$name"_blast.tsv | sort -u | while read part_name; do

        # extract all lines with that part name/query from full blast and create 'part' blast
        grep "$part_name" 4_blast_outputs/"$name"_blast.tsv > 5_blast_filtering/"$part_name"_blast.tsv
    
    done


    ##########
    # 2. take each part blast, retrieve top hit for each unique staxid sorted by e value
    ##########
    for part in 5_blast_filtering/"$name"*_blast.tsv; do

        # extract part base name
        part_name=$(basename "$part" _blast.tsv)

        # sort by staxid, then e value, then print line if unique staxid. this retrieves top blast hit for each staxid
        sort -k3,3 -k12,12g 5_blast_filtering/"$part_name"_blast.tsv | awk -F'\t' '!seen[$3]++' > top_hits.tsv

        # add taxonkit lineage for overview of blast
        cut -f3 top_hits.tsv | taxonkit lineage > lineages.tsv 

        # paste works as order/line count kept for both temp files
        paste top_hits.tsv lineages.tsv >  5_blast_filtering/"$part_name"_top_hit_per_staxid.tsv

    done

done

rm lineages.tsv 
rm top_hits.tsv



##########
# Selecting samples to manually remove based off lineage/blast filtering
##########

# remove all of sampleD_part3 based on blast results (human contamination)
rm 5_blast_filtering/sampleD_part3*

# sampleA_part1 - removing OZ205431 and OZ071514. 
# regions significantly different to others and belong to Odontoceti (87/88% pident), where rest of hits are Mysticeti (up to 97% pident)
grep -v -E 'OZ205431|OZ071514' 5_blast_filtering/sampleA_part1_top_hit_per_staxid.tsv > 5_blast_selected/sampleA_part1_selected.tsv


# sampleA_part2 - removing OZ205431, MW645456, OZ004775, and OQ554145
# 99% pident with Eubalaena on 3 hits for this, so very likely to be this genus (right whales) = Mysticeti
# will remove any hits which are not from ingroup Mysticeti (all Odontoceti again)
grep 'Mysticeti' 5_blast_filtering/sampleA_part2_top_hit_per_staxid.tsv > 5_blast_selected/sampleA_part2_selected.tsv


# sampleA_part3 - removing anything not Mysticeti
# have decided on Mysticeti as ingroup based on observations from part1 and part2
# part3 has lower overall pidents and a mix of Mysticeti and Odontoceti (Odontoceti lower across most hits however)
grep 'Mysticeti' 5_blast_filtering/sampleA_part3_top_hit_per_staxid.tsv > 5_blast_selected/sampleA_part3_selected.tsv


# all parts of sampleB - keeping the same (for now)
# only two unique staxids - both Monodontidae (only consists of 2 species - both hits, but all at 88-92%)
for sample in 5_blast_filtering/sampleB*_staxid.tsv; do
    # extract basename
    name=$(basename "$sample" _top_hit_per_staxid.tsv)

    cp "$sample" 5_blast_selected/"$name"_selected.tsv
    
done


# sampleC_part1 - keep all Thunnus, minus unclassified species MG204905 and PP661813
# this was a highly masked region but hit a lot of the Thunnus genus (true tuna), all at about 81% pident. 
grep 'Thunnus' 5_blast_filtering/sampleC_part1_top_hit_per_staxid.tsv | grep -v -E 'OZ205431|OZ071514'  > 5_blast_selected/sampleC_part1_selected.tsv


# sampleC_part2 - no hits from blast as very poor quality reads and mostly masked


# sampleC_part3 - keep all scombrinae 
# some 87-89%  pident reads of 400bp grouped around Thunnus and highest in tsv
# will also include some other scombrinae genera for phylogenetic tree downstream (about 6-8 non thunnini scombrinae present)
grep 'Scombrinae' 5_blast_filtering/sampleC_part3_top_hit_per_staxid.tsv > 5_blast_selected/sampleC_part3_selected.tsv


# sampleD_part1 
# 97-98% hits over 542bp for Dermochelys coriacea, so will keep all Americhelydia (10 hits)
grep 'Americhelydia' 5_blast_filtering/sampleD_part1_top_hit_per_staxid.tsv > 5_blast_selected/sampleD_part1_selected.tsv


# sampleD_part2
# another very strong 96% hit over 525bp (e value 0.0) for Dermochelys coriacea  
# Americhelydia clade consistently scored e values < 1e-135 so will keep an ingroup again
grep 'Americhelydia' 5_blast_filtering/sampleD_part2_top_hit_per_staxid.tsv > 5_blast_selected/sampleD_part2_selected.tsv

echo "Script 5 - BLAST filtering - complete. Find full 'part' BLAST hit and top staxid hit .tsvs in results/blast_filtering" 
echo "Find manually selected BLAST hits for downstream analysis in results/5_blast_selected"
echo
cd ..
