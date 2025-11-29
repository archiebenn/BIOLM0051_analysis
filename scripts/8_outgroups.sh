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
rm -rf 8_outgroup_FASTA 

# create output folder
mkdir -p 8_outgroup_FASTA



#########
# 2. selecting outgroup COX1 genes and fetching fasta files
#########
# using cartilaginous fishes/chondrichthyes as the outgroup clade, so will retrieve the COX1 genes for each of the below:

# Round Ribbontail Ray (Taeniura meyeni) COX1 NCBI accession: NC_019641.1
# Longtail butterfly ray (Gymnura poecilura) COX1 NCBI accession: OK393637.1 
# Bluespotted stingray (Neotrygon kuhlii) COX1 NCBI accession: PQ998246.1

# velvet belly lanternshark
efetch -db nuccore -id PX501484.1 -format fasta > 8_outgroup_FASTA/outgroups.fasta
# sharpnose sevengill shark
efetch -db nuccore -id PX466323.1 -format fasta >> 8_outgroup_FASTA/outgroups.fasta
# smooth lanternshark
efetch -db nuccore -id PV368592.1 -format fasta >> 8_outgroup_FASTA/outgroups.fasta



# arctic lamprey
#efetch -db nuccore -id LC815913.1 -format fasta > 8_outgroup_FASTA/outgroups.fasta
# asiatic brook lamprey
#efetch -db nuccore -id LC815909.1 -format fasta >> 8_outgroup_FASTA/outgroups.fasta
# southern japanese brook lamprey
#efetch -db nuccore -id LC815853.1 -format fasta >> 8_outgroup_FASTA/outgroups.fasta


#efetch -db nuccore -id OR227126.1 -format fasta > 8_outgroup_FASTA/outgroups.fasta
#efetch -db nuccore -id OK393637.1 -format fasta >> 8_outgroup_FASTA/outgroups.fasta
#efetch -db nuccore -id PQ998246.1 -format fasta >> 8_outgroup_FASTA/outgroups.fasta
