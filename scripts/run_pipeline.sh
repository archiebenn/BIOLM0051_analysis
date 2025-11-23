#!/bin/bash
# run_all.sh - runs all shell scripts in pipeline order
# run from project root

start=$(date +%s)

# strict mode - exit on errors and pipeline failures (also in every .sh script)
set -eo pipefail

# allow user to call step to start analysis from by adding an argument (no argument defaults to run full pipeline)
# 1 <= $1/argument <= final script number
# e.g to run all scripts after blast (script 4): ./scripts/run_pipeline.sh 5
start_pipeline_from=${1:-1}

cat << "EOF"
   __  _____  _____________________  __    __  __________ ______    ___   _  _____   ____  ______________
  /  |/  /\ \/ / __/_  __/ __/ _ \ \/ /   /  |/  / __/ _ /_  __/   / _ | / |/ / _ | / /\ \/ / __/  _/ __/
 / /|_/ /  \  /\ \  / / / _// , _/\  /   / /|_/ / _// __ |/ /     / __ |/    / __ |/ /__\  /\ \_/ /_\ \  
/_/  /_/   /_/___/ /_/ /___/_/|_| /_/   /_/  /_/___/_/ |_/_/     /_/ |_/_/|_/_/ |_/____//_/___/___/___/  

EOF

# 0. ensure all scripts are executable
chmod +x scripts/*


# 1. check fastq format of samples
if (( start_pipeline_from <= 1 )); then
   echo "[1] FASTQ check beginning..."
   sleep 3
   ./scripts/1_check_fastq.sh
   echo "[1] FASTQ check complete"
   echo
fi


# 2. clean single-read fastq samples and concatenate into respective multi-read fastq files
if (( start_pipeline_from <= 2 )); then
   echo "[2] FASTQ concatenation beginning..."
   sleep 3
   ./scripts/2_concatenate_fastq.sh
   echo "[2] FASTQ concatenation complete,"
   echo
fi


# 3. quality control/convert multi-read fastq files to single fasta format using seqtk 
if (( start_pipeline_from <= 3 )); then
   echo "[3] FastQC and FASTQ->FASTA beginning..."
   sleep 3
   ./scripts/3_fastq_to_fasta.sh
   echo "[3] FASTQ->FASTA complete. FastQC html reports can be found in results/3_FASTQC_reports"
   echo
fi


# 4. blast searching
if (( start_pipeline_from <= 4 )); then
   echo "[4] BLAST search beginning..."
   sleep 3
   ./scripts/4_blast.sh 
   echo "[4] BLAST searches complete."
   echo
fi


# 5. BLAST filtering
if (( start_pipeline_from <= 5 )); then
   echo "[5] Filtering BLAST hits..."
   sleep 3
   ./scripts/5_blast_filtering.sh
   echo "[5] BLAST hits filtered"
   echo
fi


# 6. manual blast selection
if (( start_pipeline_from <= 6 )); then
   echo "[6] Applying manual filters to select BLAST hits for downstream analysis..."
   sleep 3
   ./scripts/6_manual_selection.sh
   echo "[6] BLAST hits selected and saved."
fi


# 7. trimmed fasta files from top, unique accessions in each part's blast output (trimmed to query sstart - send)
if (( start_pipeline_from <= 7 )); then
   echo "[7] Retrieving and trimming selected FASTA files with efetch..."
   sleep 3
   ./scripts/7_efetch.sh
   echo "[7] efetch FASTA files retrieved and trimmed to match query."
   echo
fi


# 8. combine the original sample part to its respctive trimmed fasta file
if (( start_pipeline_from <= 8 )); then
   echo "[8] Concatenating query FASTAs with BLAST FASTAs..."
   sleep 3
   ./scripts/8_concatenate_fasta.sh
   echo "[8] FASTA concatenation complete. Find complete FASTA files in results/7_complete_FASTA"
   echo
fi


# 9. biopython to translate full fasta files and select appropriate frame for protein sequence
if (( start_pipeline_from <= 9 )); then
   echo "[9] Using Biopython to translate nt FASTA sequences and select correct frame..."
   sleep 3
   python3 scripts/9_translation.py
   echo "[9] Biopython translation and frame selection complete. Find protein sequences in results/8_protein_FASTA"
   echo
fi


# 10. alignment use muscle5
if (( start_pipeline_from <= 10 )); then
   echo "[10] Aligning protein sequences with MUSCLE..."
   sleep 3
   ./scripts/10_muscle_alignment.sh
   echo "[10] MUSCLE protein alignment complete. Find alignment files in results/9_alignment_files"
   echo
fi


# 11. tree build
if (( start_pipeline_from <= 11 )); then
   echo "[11] Building phylogenetic trees with IQ-TREE..."
   sleep 3
   ./scripts/11_build_tree.sh
   echo "[11]Phylogenetic tree builds complete. Find tree files in results/10_tree_files"
   echo
fi

end=$(date +%s)
runtime=$((end - start))
echo "Full analysis runtime: $(printf '%02dh:%02dm:%02ds\n' $((runtime/3600)) $((runtime%3600/60)) $((runtime%60)))"
