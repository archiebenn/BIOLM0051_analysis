#!/bin/bash

# move into results/ (if running outside project root 'cd data/' will fail and an error message is printed)
cd results || \
{ echo "Samples directory not found, please ensure you are running this script from project root"; exit 1; }

# make blast results folder
mkdir -p blast_output

for fasta in FASTA_processed/*.fasta; do

    # extract file base name
    name=$(basename "$fasta" _q20.fasta)

    echo
    echo "Carrying out a BLAST search on "$fasta"..."

    # run blastn nucleotide search remotely and save hits as a .tsv file (can be adapted for running on hpc with local db)
    blastn -query "$fasta" -db nt -out "$name"_blast.tsv -outfmt 6 -remote

    # create a blast log to detail run date/version/input etc. (even if version locked in micromamba env)
    {
        echo "=== BLAST log for "$name"_blast.tsv ==="
        date
        blastn -version

        echo "Command used:"
        echo "blastn -query "$fasta" -db nt -out "$name"_blast.tsv -outfmt 6 -remote"
        
    } > "$name"_blast.log

    # move both into blast folder
    mv "$name"_blast.tsv "$name"_blast.log blast_output/

done

echo "BLAST searches complete. Find blast tsvs and log files in results/blast_output/"
cd ..