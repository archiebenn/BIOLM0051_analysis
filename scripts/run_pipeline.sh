#!/bin/bash
# run_all.sh - runs all shell scripts in pipeline order
# run from project root

start=$(date +%s)

# strict mode - exit on errors and pipeline failures (also in every .sh script)
set -eo pipefail

cat << "EOF"
   __  _____  _____________________  __    __  __________ ______    ___   _  _____   ____  ______________
  /  |/  /\ \/ / __/_  __/ __/ _ \ \/ /   /  |/  / __/ _ /_  __/   / _ | / |/ / _ | / /\ \/ / __/  _/ __/
 / /|_/ /  \  /\ \  / / / _// , _/\  /   / /|_/ / _// __ |/ /     / __ |/    / __ |/ /__\  /\ \_/ /_\ \  
/_/  /_/   /_/___/ /_/ /___/_/|_| /_/   /_/  /_/___/_/ |_/_/     /_/ |_/_/|_/_/ |_/____//_/___/___/___/  

EOF

# 0. ensure all scripts are executable
chmod +x scripts/*

# 1. check fastq format of samples
echo "[1] FASTQ check beginning..."
sleep 3
./scripts/1_check_fastq.sh
echo "[1] FASTQ check complete"
echo

# 2. clean single-read fastq samples and concatenate into respective multi-read fastq files
echo "[2] FASTQ concatenation beginning..."
sleep 3
./scripts/2_concatenate_fastq.sh
echo "[2] FASTQ concatenation complete,"
echo

# 3. quality control/convert multi-read fastq files to single fasta format using seqtk 
echo "[3] FastQC and FASTQ->FASTA beginning..."
sleep 3
./scripts/3_fastq_to_fasta.sh
echo "[3] FASTQ->FASTA complete. FastQC html reports can be found in results/3_FASTQC_reports"
echo

# 4. blast searching
echo "[4] BLAST search beginning..."
sleep 3
./scripts/4_blast.sh 
echo "[4] BLAST searches complete."
echo

# 5. BLAST filtering
echo "[5] Filtering BLAST hits..."
sleep 3
./scripts/5_blast_filtering.sh
echo "[5] BLAST hits filtered"
echo

# 6. manual blast selection
echo "[6] Applying manual filters to select BLAST hits for downstream analysis..."
sleep 3
./scripts/6_manual_selection.sh
echo "[6] BLAST hits selected and saved."

# 7. trimmed fasta files from top, unique accessions in each part's blast output (trimmed to query sstart - send)
echo "[7] Retrieving and trimming selected FASTA files with efetch..."
sleep 3
./scripts/7_efetch.sh
echo "[7] efetch FASTA files retrieved and trimmed to match query."
echo

# 8. combine the original sample part to its respctive trimmed fasta file
echo "[8] Concatenating query FASTAs with BLAST FASTAs..."
sleep 3
./scripts/8_concatenate_fasta.sh
echo "[8] FASTA concatenation complete. Find complete FASTA files in results/7_complete_FASTA"
echo

# 9. biopython to translate full fasta files and select appropriate frame for protein sequence
echo "[9] Using Biopython to translate nt FASTA sequences and select correct frame..."
sleep 3
python3 scripts/9_translation.py
echo "[9] Biopython translation and frame selection complete. Find protein sequences in results/8_protein_FASTA"
echo


# 10. alignment use muscle5
echo "[10] Aligning protein sequences with MUSCLE..."
sleep 3
./scripts/10_muscle_alignment.sh
echo "[10] MUSCLE protein alignment complete. Find alignment files in results/9_alignment_files"
echo

# 11. tree build
echo "[11] Building phylogenetic trees with IQ-TREE..."
sleep 3
./scripts/11_build_tree.sh
echo "[11]Phylogenetic tree builds complete. Find tree files in results/10_tree_files"
echo

end=$(date +%s)
runtime=$((end - start))
echo "Full analysis runtime: $(printf '%02dh:%02dm:%02ds\n' $((runtime/3600)) $((runtime%3600/60)) $((runtime%60)))"
