#!/bin/bash
# run_all.sh - runs all shell scripts in order 
# run from project root

# 0. ensure all scripts are executable
chmod +x scripts/*

# 1. check fastq format of samples
./scripts/check_fastq.sh

# 2. concatenate fastq samples into respective sample multi-read fastq files
./scripts/concatenate_fastq.sh

# 3. convert multi-read fastq files to i swear there we