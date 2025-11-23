# 11_phylo_tree.py - to automate generating preliminary phylogenetic trees

import os
import matplotlib.pyplot as plt
from Bio import Phylo

os.makedirs("../results/12_phylo_trees", exist_ok=True)

treefile_directory  = "../results/11_tree_files"
results_directory = "../results/12_phylo_trees"

# use biopython Phylo to draw tree from treefile. optional outgroup file
def view_tree(treefile_path, filename, outgroup_as_str=None):

    # IQ-TREE .treefile is newick
    tree = Phylo.read(treefile_path, "newick")

    if outgroup_as_str:
        tree.root_with_outgroup(outgroup_as_str)
    else:
        print(f"{filename} outgroup not provided, making unrooted tree")

    Phylo.draw(tree)

    plt.savefig(f"{results_directory}/{filename}_tree.pdf")

    plt.close()


view_tree(f"{treefile_directory}/sampleC_part3_alignment.afa.treefile", "sampleC_part3")


