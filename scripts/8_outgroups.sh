#!/bin/bash
# 8_outgroups.sh fetches outgroup fasta files for downstream trees
# run from project root

##########
# 1. setup and error handling
##########

# strict mode - exit on errors and pipeline failures
set -eo pipefail

# move into results/ and exit if not in root
cd results || \
{ echo "Results directory not found, please ensure you are running this script from project root"; exit 1; }

# remove output folder if it exists (if re-running with existing results/))
rm -rf 8_outgroup_FASTA 8_outgroup_db

# create output folder
mkdir -p 8_outgroup_FASTA
mkdir -p 8_outgroup_db



#########
# 2. selecting outgroup COX1 genes and fetching fasta files
#########
# using cartilaginous fishes/chondrichthyes as the outgroup clade, so will retrieve the COX1 genes for each of the below:

# Round Ribbontail Ray (Taeniura meyeni) COX1 NCBI accession: OR227126.1
# Longtail butterfly ray (Gymnura poecilura) COX1 NCBI accession: OK393637.1 
# Bluespotted stingray (Neotrygon kuhlii) COX1 NCBI accession: PQ998246.1

# fetching the accession fasta files of the above
efetch -db nuccore -id OR227126.1 -format fasta > 8_outgroup_FASTA/outgroups.fasta
efetch -db nuccore -id OK393637.1 -format fasta >> 8_outgroup_FASTA/outgroups.fasta
efetch -db nuccore -id PQ998246.1 -format fasta >> 8_outgroup_FASTA/outgroups.fasta



#########
# 3. local alignment to match query parts to thhe outgroup cox1 genes
#########

# make a blast database from the outgroup fasta files
makeblastdb -in 8_outgroup_FASTA/outgroups.fasta -dbtype nucl -parse_seqids -out 8_outgroup_db/outgroup_db

# run a local blast of a part 1 file (used sampleA) against this outgroup database
blastn -query 7_efetch_FASTA/sampleA_part1.fasta -db 8_outgroup_db/outgroup_db -out 8_outgroup_FASTA/part1_outgroup.fasta -outfmt "6 qseqid sstart send"

# run a local blast of a part 2 file (used sampleA) against this outgroup database
blastn -query 7_efetch_FASTA/sampleA_part2.fasta -db 8_outgroup_db/outgroup_db -out 8_outgroup_FASTA/part2_outgroup.fasta -outfmt "6 qseqid sstart send"

# run a local blast of a part 3 file (used sampleB) against this outgroup database
blastn -query 7_efetch_FASTA/sampleB_part3.fasta -db 8_outgroup_db/outgroup_db -out 8_outgroup_FASTA/part3_outgroup.fasta -outfmt "6 qseqid sstart send"