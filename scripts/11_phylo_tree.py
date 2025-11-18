# 8_translation.py - a python script to translate the complete FASTA sequences from part 7 of analysis

from Bio import Phylo

tree = Phylo.read("../results/8_protein_FASTA/alignment_test.afa.treefile", "newick")

Phylo.draw(tree)
