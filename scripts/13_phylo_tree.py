# 13_view_tree.py -  generate and export phylogenetic trees from the .treefiles

import shutil
import os
import matplotlib.pyplot as plt
from Bio import Phylo


##########
# 1. setup and error handling
##########

# remove output folder if it exists (if re-running with existing results/))
shutil.rmtree("results/13_tree_plots", ignore_errors=True)

# make output folder
os.makedirs("results/13_tree_plots", exist_ok=True)

# set input and output directories
treefile_directory = "results/12_tree_files"
results_directory = "results/13_tree_plots"


##########
# 2. create tree and root it with outgroup
##########

# define tree to be read (.treefile is newick)
full_tree = Phylo.read(f"{treefile_directory}/partition.txt.treefile", "newick")

# define outgroup organisms in a list as they appear in .afa headers
outgroup_names = ["Etmopterus_spinax", "Heptranchias_perlo", "Etmopterus_pusillus"]

# find common ancestor node of the unrooted tree given the outgroup list (sharks)
shark_clade = full_tree.common_ancestor(outgroup_names)

# root tree at outgroup clade common ancestor
full_tree.root_with_outgroup(shark_clade)

# tree aesthetics
# widen plot branches
for clade in full_tree.find_clades():
    clade.width = 1.25

# hide bootstrap labels
for clade in full_tree.get_nonterminals():
    clade.name = None

# resize the plot
fig = plt.figure(figsize=(12, 10))
ax = fig.add_subplot(1, 1, 1)

# draw the tree and save out to results directory
Phylo.draw(full_tree, axes=ax, do_show=False)

# save out the svg
plt.savefig(f"{results_directory}/samples_tree.svg")
plt.close()
