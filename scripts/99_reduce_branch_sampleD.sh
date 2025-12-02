#!/bin/bash
# 99_reduce_branch_sampleD.sh - an investigation into the long branch length of sampleD in the phylogenetic tree
# run from project root

# this script does not form part of the main pipeline and is a subsequent analysis on manually edited data



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
# 2. Assessing sampleD_part1 nucleotide sequence against closest reference to try and understand long branch length
##########

# to determine why sampleD branch length is so long in tree plot
# looked at supermatrix.afa and noticed around 130-160 region that sampleD doesn't follow a highly conserved motif 
# this is SSILGAINFITT where sampleD = SSILGAITSLLQ, indicating a frameshift in this region
# will carry out a global alignment of sampleD_part1 tail (this region) vs. its closest reference on the tree Dermochelys coriacea (JX454969)

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


# to re-run the analysis as a test, I edited the missing base in 9_complete_FASTA for sampleD_part1. 
# inserted an ambiguous N into position 486, to go from:
# ...GCTATTACTTCATTACTACAG...
# to
# ...GCTATTNACTTCATTACTACAG...
# then re-ran the pipeline using ./scripts/run_pipeline.sh 10 to run from script 10 -> end with this edited base

# change base in sampleD_part1
sed -i 's/GCTATTACTTCATTACTACAG/GCTATTNACTTCATTACTACAG/g' 9_complete_FASTA/part1_complete.fasta

# move back to project root to run pipeline 
cd ..

# re-run analysis from script 10 -> end
echo "[99] Re-running pipeline with manually edited base in sampleD_part1 nucleotide sequence"
echo
./scripts/pipeline.sh 10
echo
echo "[99] Pipeline with manually edited sampleD_part1 base successfully finished. Find updated tree plot in results/13_tree_plots"

# return to original sequence after analysis
sed -i 's/GCTATTNACTTCATTACTACAG/GCTATTACTTCATTACTACAG/g' results/9_complete_FASTA/part1_complete.fasta