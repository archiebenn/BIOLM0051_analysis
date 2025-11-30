#!/bin/bash
# 99_subsequent_analysis.sh - a shell script for any further investigation outside the pipeline
# run from project root

##########
# 1. setup and error handling
##########

# move into results/ and exit if not in root
cd results || \
{ echo "Results directory not found, please ensure you are running this script from project root"; exit 1; }

# remove output folder if it exists (if re-running with existing results/))
rm -rf 99_needleman_wunsch
mkdir -p 99_needleman_wunsch

##########
# 2. Assessing sampleD_part1 nucleotide sequence against closest reference
##########

# wanted to see why the sampleD branch length is so long in tree plot
# looked at supermatrix.afa and noticed around 130-160 region that sampleD doesn't follow a high;y conserved motif 
# this is SSILGAINFITT - bu sampleD is SSILGAITSLLQ, indicating a frameshift in this region
# want to do a global alignment of sampleD_part1 tail (this region) vs. its closest reference on the tree Dermochelys coriacea (JX454969)

# copy-paste from 9_complete_FASTA/part1_complete.fasta
echo ">Dermochelys_coriacea
CTCGCTGATTTTTTTCTACTAATCATAAAGACATTGGCACCCTATACCTAATTTTTGGGGCCTGAGCAGGAATAGTAGGCACAGCACTCAGCCTATTAATCCGTGCAGAACTAAGCCAACCGGGAACCCTCCTAGGAGATGACCAAATTTACAATGTCATCGTTACAGCCCATGCCTTCATTATAATCTTCTTCATAGTTATACCAGTTATAATCGGCGGTTTCGGAAACTGACTTGTTCCCCTTATAATTGGAGCACCAGACATGGCATTCCCACGAATAAACAACATAAGCTTTTGACTTTTACCTCCCTCACTGTTACTACTTCTAGCATCATCAGGAATTGAAGCAGGTGCAGGAACAGGCTGAACAGTCTATCCTCCACTAGCTGGAAACCTAGCCCACGCTGGTGCTTCTGTAGACCTAACTATCTTTTCTCTGCACCTAGCTGGTGTTTCATCAATTTTAGGAGCTATTAACTTCATTACTACAGCAATCAACATAAAATCTCCAGCT
" > 99_needleman_wunsch/d_coriacea.fasta

# copy-paste from 9_complete_FASTA/part1_complete.fasta
echo ">sampleD_part1
NNNNNNNNNNCTCGCTGATTTTTTTCTACTAATCATAAAGACATTGGCACCCTATACCTA
ATTTTTGGGGCCTGAGCAGGAATAGTAGGCACAGCACTCAGCCTATTAATCCGTGCAGAA
CTAAGCCAACCGGGAACCCTCCTAGGAGATGACCAAATTTACAATGTCATCGTTACAGCC
CATGCCTTCATTATAATCTTCTTCATAGTTATACCAGTTATAATCGGCGGTTTCGGAAAC
TGACTTGTTCCCCTTATAATTGGAGCACCAGACATGGCATTCCCACGAATAAACAACATA
AGCTTTTGNNNNNNNNCTCCCTCACTGTTACTACTTCTAGCATCATCAGGAATTGAAGCA
GGTGCAGGAACAGGCTGAACAGTCTATCCTCCACTAGCTGGAAACCTAGCCCACGCTGGT
GCTTCTGTAGACCTAACTATCTTTTCTCTGCACCTAGCTGGTGTTTCATCAATTTTAGGA
GCTATTACTTCATTACTACAGCAATCAACATAAAATCTCCAGCT
" > 99_needleman_wunsch/sampleD_part1.fasta

# run a needleman-wunsch pairwise global alignment with mafft of sampleD_part1 against Dermochelys coriacea to find any potential gaps
needle -asequence 99_needleman_wunsch/d_coriacea.fasta -bsequence 99_needleman_wunsch/sampleD_part1.fasta -gapopen 10 -gapextend 0.5 -outfile 99_needleman_wunsch/n-w_global_alignment.txt
