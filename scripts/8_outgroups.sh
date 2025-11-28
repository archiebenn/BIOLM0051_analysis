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
# 2. selecting outgroups and fetching fasta files
#########
# using cartilaginous fishes/chondrichthyes as the outgroup clade, some full mt genome accessions of rays below:

# Round Ribbontail Ray (Taeniura meyeni) full mt genome accession: NC_019641
# Longtail butterfly ray (Gymnura poecilura) full mt genome accession: NC_024102 
# Bluespotted stingray (Neotrygon kuhlii) full voucher mt genome accession: KR019777

# fetching the accession fasta files of the above
efetch -db nuccore -id "NC_019641" -format fasta > 8_outgroup_FASTA/t_meyeni.fasta
efetch -db nuccore -id "NC_024102" -format fasta > 8_outgroup_FASTA/g_poecilura.fasta
efetch -db nuccore -id "KR019777" -format fasta > 8_outgroup_FASTA/n_kuhlii.fasta