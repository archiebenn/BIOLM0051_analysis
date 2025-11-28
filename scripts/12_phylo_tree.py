# 11_phylo_tree.py - to automate generating the phylogenetic tree pdfs from the .treefiles
import shutil
import os
import matplotlib.pyplot as plt
from Bio import Phylo

# remove output folder if it exists (if re-running with existing results/))
shutil.rmtree("results/12_tree_pdfs", ignore_errors=True)

# make outputs folder
os.makedirs("results/12_tree_pdfs", exist_ok=True)

# set input directories
treefile_directory = "results/11_tree_files"
results_directory = "results/12_phylo_trees"


# part 1 tree (.treefile is newick)
part1_tree = Phylo.read(f"{treefile_directory}/part1_alignment.afa.treefile", "newick")

part1_tree.root_with_outgroup(outgroup_as_str)

Phylo.draw(part1_tree)
plt.savefig(f"{results_directory}/part1_tree.pdf")
plt.close()

view_tree(f"{treefile_directory}/sampleC_part3_alignment.afa.treefile", "sampleC_part3")


# part 2 tree (.treefile is newick)
part2_tree = Phylo.read(f"{treefile_directory}/part2_alignment.afa.treefile", "newick")

part2_tree.root_with_outgroup(outgroup_as_str)

Phylo.draw(part1_tree)
plt.savefig(f"{results_directory}/part3_tree.pdf")
plt.close()

view_tree(f"{treefile_directory}/sampleC_part3_alignment.afa.treefile", "sampleC_part3")


# part 3 tree (.treefile is newick)
part3_tree = Phylo.read(f"{treefile_directory}/part3_alignment.afa.treefile", "newick")

part3_tree.root_with_outgroup(outgroup_as_str)

Phylo.draw(part3_tree)
plt.savefig(f"{results_directory}/part3_tree.pdf")
plt.close()

view_tree(f"{treefile_directory}/sampleC_part3_alignment.afa.treefile", "sampleC_part3")


# supermatrix tree (.treefile is newick)
tree = Phylo.read(f"{treefile_directory}/partition.txt.treefile", "newick")

tree.root_with_outgroup(outgroup_as_str)

Phylo.draw(tree)

plt.savefig(f"{results_directory}/{filename}_tree.pdf")

plt.close()

view_tree(f"{treefile_directory}/sampleC_part3_alignment.afa.treefile", "sampleC_part3")
