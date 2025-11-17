#!/bin/bash
# blast.sh - uses processed fasta file and carries out a blast nucletotide search. outputs in tsv format in results folder

# move into results/ 
cd results || \
{ echo "Results directory not found, please ensure you are running this script from project root"; exit 1; }

# make blast results folder
mkdir -p 4_blast_outputs

for fasta in 3_FASTA_Q20/*.fasta; do

    # extract file base name
    name=$(basename "$fasta" _Q20.fasta)

    echo
    echo "Carrying out a BLAST search on "$name"..."

    # run blastn nucleotide search remotely and save hits as a .tsv file with headers/comments (7) (can be adapted for running on hpc with local db)
    blastn -query "$fasta" -db nt -out "$name"_blast.tsv -outfmt "6 qseqid sacc staxids pident length mismatch gapopen qstart qend sstart send evalue bitscore" -remote

    # create a blast log to detail run date/version/input etc for transparency
    {
        echo "--- BLAST log ---"
        date
        blastn -version

        echo "Command used:"
        echo "blastn -query "$fasta" -db nt -out "$name"_blast.tsv -outfmt \"6 qseqid sacc staxids pident length mismatch gapopen qstart qend sstart send evalue bitscore\" -remote"
        
    } > "$name"_blast.log

    # move both into blast folder
    mv "$name"_blast.tsv "$name"_blast.log 4_blast_outputs/
    
done

echo "BLAST searches complete. Find blast tsvs and log files in results/4_blast_outputs/"
cd ..