#!/bin/bash
# efetch.sh - script to use accession numbers to retrieve fasta files from blast output for each part and sample, with trimming to fit sstart and send from blast query
# run from project root

# move into results/ 
cd results || \
{ echo "Results directory not found, please ensure you are running this script from project root"; exit 1; }

mkdir -p 6_efetch_FASTA

# remove sampleD_part3 based on blast results (human contamination)
rm 5_blast_filtering/sampleD_part3.*

for tsv in 5_blast_filtering/*_top_hit_per_staxid.tsv; do

    # extract base name
    part_name=$(basename "$tsv" _top_hit_per_staxid.tsv)

    echo "Retrieving and trimming FASTA files for "$part_name""
    echo 

    ##########
    # 1. retrieve blast values from tsvs
    ##########

    # extract accession values, sstart, and send from each tsv. choosing top 15
    cut -f2,10,11 5_blast_filtering/"$part_name"_top_hit_per_staxid.tsv | head -n 15 > 6_efetch_FASTA/"$part_name"_blast.tsv

    ##########
    # 2. get fasta and trim from sstart -> send
    ##########

    # reset fasta file
    > 6_efetch_FASTA/"$part_name".fasta

    # read accession, sstart, and send from 'part' tsv
    while IFS=$'\t' read accession sstart send; do

        # normalising strand direction for seqtk to use: 
        # forward strand: sstart < send
        if [ "$sstart" -lt "$send" ]; then 

            # seqtk uses 0-indexed start and 1-indexed end:
            seqstart=$((sstart - 1))
            seqend=$send

        # reverse strand: sstart > send, swap sstart and send 
        else 
            seqstart=$((send - 1))
            seqend=$sstart
        fi

        # retrieve full accession fasta sequence using efetch and store in temp file 
        efetch -db nuccore -format fasta -id "$accession" > temp_full.fasta

        # extract fasta header for seqtk (without '>')
        seqname=$(head -1 temp_full.fasta | sed 's/^>//' | cut -d' ' -f1)

        # send values into a .bed file for genomic region coordinates
        echo -e "${seqname}\t$((seqstart))\t${seqend}" > accession_start_end.bed

        # trim full fasta using bed coordinates. reverse complement if needed as well to match query strand
        seqtk subseq temp_full.fasta accession_start_end.bed > temp_trimmed.fasta

        # check if output orientation requires reverse complement for downstream translation (if from reverse strand)
        if [ "$sstart" -gt "$send" ]; then 

            # seqtk reverse complement function
            seqtk seq -r temp_trimmed.fasta >> 6_efetch_FASTA/"$part_name".fasta
        
        # case for forward strand = keep same
        else 
            cat temp_trimmed.fasta >> 6_efetch_FASTA/"$part_name".fasta
        fi

        rm temp_trimmed.fasta
        rm temp_full.fasta
        rm accession_start_end.bed

    # read from 'part' blast tsv file
    done < 6_efetch_FASTA/"$part_name"_blast.tsv

    rm 6_efetch_FASTA/"$part_name"_blast.tsv

done

echo "FASTA files from BLAST search retrieved and trimmed to match query sequence hits. Find the FASTA files in results/6_efetch_FASTA"

cd ..
