#!/bin/bash
# run_all.sh - runs all shell scripts in pipeline order
# run from project root

start=$(date +%s)

# 0. ensure all scripts are executable
chmod +x scripts/*

# 1. check fastq format of samples
# ./scripts/1_check_fastq.sh

# 2. clean single-read fastq samples and concatenate into respective multi-read fastq files
# ./scripts/2_concatenate_fastq.sh

# 3. quality control/convert multi-read fastq files to single fasta format using seqtk 
# ./scripts/3_fastq_to_fasta.sh

# 4. blast searching
# ./scripts/4_blast.sh 

# 5. taxonomies from blast
./scripts/5_blast_filtering.sh

# 6. trimmed fasta files from top, unique accessions in each part's blast output (trimmed to query sstart - send)
./scripts/6_efetch.sh

# 7. combine the original sample part to its respctive trimmed fasta file
./scripts/7_concantenate_fasta.sh

# 8. biopython to translate full fasta files and select appropriate frame for protein sequence
python3 ./scripts/8_translation.py

# 9. alignment use muscle5
./scripts/9_muscle_alignment.sh

end=$(date +%s)
runtime=$((end - start))
echo "Full analysis runtime: $(printf '%02dh:%02dm:%02ds\n' $((runtime/3600)) $((runtime%3600/60)) $((runtime%60)))"