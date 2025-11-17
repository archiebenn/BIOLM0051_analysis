#!/bin/bash
# blast_filtering.sh - separates blast output back into parts 1, 2 and 3, creates taxonomy overview, and selectes top blast hit for each staxid 
# run from project root 

# move into results/ 
cd results || \
{ echo "Results directory not found, please ensure you are running this script from project root"; exit 1; }

mkdir -p 5_blast_filtering

for tsv in 4_blast_outputs/*.tsv; do

    ##########
    # 1.split main blast output into each samples' parts:
    ##########

    # extract base name
    name=$(basename "$tsv" _blast.tsv)

    echo "Splitting sample back into parts, generating likely taxonomic lineages, and sorting BLAST data per staxid for "$name""

    # take the query sequence name and retrieve blast hits for that part
    awk -F'\t' -v out="5_blast_filtering/" '{print > (out "/" $1 "_blast.tsv")}' 4_blast_outputs/"$name"_blast.tsv

    ##########
    # 2. filter on high % identity + length for each part - strong filter for species likelihood
    ##########
    for part in 5_blast_filtering/"$name"*_blast.tsv; do

        # extract part base name
        part_name=$(basename "$part" _blast.tsv)

        # filter for 95%+ %identity and minimum 100nt length
        awk '$4 >= 95 && $5 >= 100' 5_blast_filtering/"$part_name"_blast.tsv > 5_blast_filtering/"$part_name"_blast_species.tsv

        # take staxid, pident, length, evalue for filtered hits and select top one for each staxid. sorted by highest pident
        cut -f3,4,5,12 5_blast_filtering/"$part_name"_blast_species.tsv | sort -k2,2nr | awk '!seen[$1]++' > acc_pid_ev.tsv
        
        # run taxonkit lineage on the staxids
        cut -f1 acc_pid_ev.tsv | taxonkit lineage > lineage_hits.tsv

        # combine accession, pident, evalue, and taxonkit lineage for 'likely taxonomy' overview
        echo -e "staxid\tpident\tlength\tevalue\ttaxonkit_lineage" > 5_blast_filtering/"$part_name"_likely_taxonomy.txt
        paste acc_pid_ev.tsv lineage_hits.tsv >> 5_blast_filtering/"$part_name"_likely_taxonomy.txt

        # explanation in empty 'likely taxonomy' files (ie. if lineage hits empty)
        if [ ! -s lineage_hits.tsv ]; then
            echo "No hits returned with >= 95% identity and >= 100nt in length from "$part_name". No confidence in species level determination from this sequence." >> 5_blast_filtering/"$part_name"_likely_taxonomy.txt
        fi

        rm 5_blast_filtering/"$part_name"_blast_species.tsv
        rm acc_pid_ev.tsv 
        rm lineage_hits.tsv

    ##########
    # 3 .retrieve top blast hit of each unique staxid - more general to allow varied phylogenies downstream:
    ##########

        # sort by staxid, then evalue, then print line if unique staxid. this retrieves top blast hit for each staxid
        sort -k3,3 -k12,12g 5_blast_filtering/"$part_name"_blast.tsv | awk -F'\t' '!seen[$3]++' > 5_blast_filtering/"$part_name"_top_hit_per_staxid.tsv

    done

done

cd ..
