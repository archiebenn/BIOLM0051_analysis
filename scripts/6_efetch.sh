#!/bin/bash
# efetch.sh - script to use accession numbers to retrieve fasta files from blast output for each part and sample, with trimming to fit sstart and send from blast query

# move into results/ (if running outside project root 'cd data/' will fail and an error message is printed)
cd results || \
{ echo "Samples directory not found, please ensure you are running this script from project root"; exit 1; }

mkdir -p 6_efetch_FASTA

for tsv in 5_blast_filtering/*_unique_taxa.tsv; do

    # extract base name
    part_name=$(basename "$tsv" _unique_taxa.tsv)

    echo "Retrieving and trimming FASTA files for "$part_name""
    echo 

    ##########
    # 1. retrieve blast values
    ##########
    # extract sample's/part's accession values, sstart, and send from each tsv. choosing top 15
    cut -f2,10,11 5_blast_filtering/"$part_name"_unique_taxa.tsv | head -n 15 > 6_efetch_FASTA/"$part_name"_blast.tsv

    ##########
    # 2. get fasta and trim from sstart -> send
    ##########
    # empty out final fasta file (in case of re-running as uses >> below)
    > 6_efetch_FASTA/"$part_name".fasta

    # uses 'internal field separator' for tsv and reads blast file line by line, sets each column name as the 3 variables listed
    while IFS=$'\t' read accession sstart send; do

        # check on forward vs reverse strand based on sstart and send values from blast
        # forward strand case where sstart < send
        if [ "$sstart" -lt "$send" ]; then 

            # -1 off start as seqtk subseq will use start as 0 indexed start but 1 indexed end
            seqstart=$((sstart - 1))
            seqend=$send

        # reverse strand case
        else 
            seqstart=$((send - 1))
            seqend=$sstart
        fi

        # retrieve full accession fasta sequence using efetch and store in temp file 
        efetch -db nuccore -format fasta -id "$accession" > temp_full.fasta

        # retrieve fasta header to use in seqtk subseq below (bed format required must be fasta_header_id start end)
        # seqname becomes fasta file header, minus the >, then cuts header at space and keeps first field only
        seqname=$(head -1 temp_full.fasta | sed 's/^>//' | cut -d' ' -f1)

        # send these values into a .bed file (text file format for storing genomic regions as coordinates)
        echo -e "${seqname}\t$((seqstart))\t${seqend}" > accession_start_end.bed

        # trim full fasta using bed coordinates generated above (seqtk subseq format: file bed_coordinates) 
        seqtk subseq temp_full.fasta accession_start_end.bed >> 6_efetch_FASTA/"$part_name".fasta

        # remove unnecesary files generated in this loop
        rm temp_full.fasta
        rm accession_start_end.bed

    # while loop reads from 'part' blast tsv file (top 20)
    done < 6_efetch_FASTA/"$part_name"_blast.tsv

    # remove file made in this loop
    rm 6_efetch_FASTA/"$part_name"_blast.tsv

done

echo "FASTA files from BLAST search retrieved and trimmed to match query sequence hits"

cd ..