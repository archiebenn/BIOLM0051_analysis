#!/bin/bash
# blast.sh - uses processed fasta file and carries out a blast nucletotide search. outputs in tsv format in results folder

##########
# 1. setup and error handling
##########

# strict mode - exit on errors and pipeline failures
set -eo pipefail

# move into results/ and exit if not in root
cd results || \
{ echo "Results directory not found, please ensure you are running this script from project root"; exit 1; }

# make blast results folder
mkdir -p 4_blast_outputs

# set input folder to read from
input_dir=3_FASTA_Q20

# check that the input folder from previous script contains files for the loop (and silences internal errors)
ls "$input_dir"/*.fasta >/dev/null 2>&1 || \
{ echo "[ISSUE] No files found in $input_dir. Previous script may have failed. Exiting script."; exit 1; }



##########
# 2. main script loop to carry out blast search:
##########

# loops through each processed FASTA file
for fasta in "$input_dir"/*.fasta; do

    # extract file base name
    name=$(basename "$fasta" _Q20.fasta)

    echo "Carrying out a BLAST search on $name..."

    # run blastn nucleotide search remotely and save hits as a .tsv file with headers/comments (7) (can be adapted for running on hpc with local db)
    blastn -query "$fasta" -db nt -out "$name"_blast.tsv -outfmt "6 qseqid sacc staxids pident length mismatch gapopen qstart qend sstart send evalue bitscore" -remote

    # create a blast log to detail run date/version/input etc for transparency
    {
        echo "--- BLAST log ---"
        date
        blastn -version

        echo "Command used:"
        echo "blastn -query $fasta -db nt -out "$name"_blast.tsv -outfmt \"6 qseqid sacc staxids pident length mismatch gapopen qstart qend sstart send evalue bitscore\" -remote"
        
    } > "$name"_blast.log

    # move both into blast folder
    mv "$name"_blast.tsv "$name"_blast.log 4_blast_outputs/
    
done

cd ..