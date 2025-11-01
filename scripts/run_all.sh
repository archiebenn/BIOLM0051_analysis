#!/bin/bash
# run_all.sh - runs all shell scripts in order (for modularity while debugging) with some notes as i go along for each step (for me)
# run from project root

# 0. ensure all scripts are executable
chmod +x scripts/*

# 1. check fastq format of samples
./scripts/check_fastq.sh

# 2. clean single-read fastq samples and concatenate into respective multi-read fastq files
./scripts/concatenate_fastq.sh

# 3. quality control/convert multi-read fastq files to single fasta format using seqtk 
./scripts/fastq_to_fasta.sh

# 4. blast searching
./scripts/blast.sh