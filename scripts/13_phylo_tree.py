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

# serif font
plt.rcParams["font.family"] = "serif"


##########
# 2. create 'non-bootstrapped' tree and root it with outgroup
##########

# define tree to be read (.treefile is newick)
full_tree = Phylo.read(f"{treefile_directory}/partition.txt.treefile", "newick")

# define outgroup organisms in a list as they appear in .afa headers
outgroup_names = ["Etmopterus_spinax", "Heptranchias_perlo", "Etmopterus_pusillus"]

# find common ancestor node of the unrooted tree given the outgroup list (sharks)
shark_clade = full_tree.common_ancestor(outgroup_names)

# root tree at outgroup clade common ancestor
full_tree.root_with_outgroup(shark_clade)


##########
# 3. tree aesthetics
##########

# widen plot branches
for clade in full_tree.find_clades():
    clade.width = 1.25

# resize the plot to fit a4 landscape
fig = plt.figure(figsize=(12, 10))
ax = fig.add_subplot(1, 1, 1)

# hide bootstrap labels for report tree as cluttered
for clade in full_tree.get_nonterminals():
    clade.confidence = None

# flip branches in y axis
full_tree.ladderize()

# draw the tree
Phylo.draw(full_tree, axes=ax, do_show=False)


# set sample tips in red after drawing tree
for text in ax.texts:
    label = text.get_text().strip()
    # if label starts with 'sample' colour it firebrick
    if label.startswith("sample"):
        text.set_color("firebrick")

# set tip label size
for text in ax.texts:
    text.set_fontsize(13)

# title and axes labels
plt.xlabel("Substitutions per site", labelpad=12, fontsize=16)
plt.ylabel("")

# remove y ticks
ax.set_yticks([])

# set tick font size
ax.tick_params(axis="x", labelsize=12)

# reduce border size
plt.tight_layout(pad=0)

# save out the pdf
plt.savefig(f"{results_directory}/final_tree.pdf")
plt.close()


##########
# 4. re-making for a tree to be saved which includes bootstrap values at nodes
##########

# define tree to be read (.treefile is newick)
full_tree = Phylo.read(f"{treefile_directory}/partition.txt.treefile", "newick")

# define outgroup organisms in a list as they appear in .afa headers
outgroup_names = ["Etmopterus_spinax", "Heptranchias_perlo", "Etmopterus_pusillus"]

# find common ancestor node of the unrooted tree given the outgroup list (sharks)
shark_clade = full_tree.common_ancestor(outgroup_names)

# root tree at outgroup clade common ancestor
full_tree.root_with_outgroup(shark_clade)


##########
# 3. bootstrap tree aesthetics
##########

# widen plot branches
for clade in full_tree.find_clades():
    clade.width = 1

# resize the plot to fit a4 landscape
fig = plt.figure(figsize=(12, 10))
ax = fig.add_subplot(1, 1, 1)


# flip branches in y axis
full_tree.ladderize()

# draw the tree
Phylo.draw(full_tree, axes=ax, do_show=False)


mrca_tuna = full_tree.common_ancestor(
    {"name": "Thunnus_albacares"},
    {"name": "Thunnus_orientalis"},
    {"name": "Thunnus_thynnus"},
    {"name": "Thunnus_maccoyii"},
    {"name": "Thunnus_obesus"},
    {"name": "sampleC"},
    {"name": "Thunnus_tonggol"},
)
mrca_tuna.color = "salmon"


# set sample tips in red after drawing tree
for text in ax.texts:
    label = text.get_text().strip()
    # if label starts with 'sample' colour it firebrick
    if label.startswith("sample"):
        text.set_color("firebrick")

# set tip label size
for text in ax.texts:
    text.set_fontsize(13)

# title and axes labels
plt.xlabel("Substitutions per site", labelpad=12, fontsize=16)
plt.ylabel("")

# remove y ticks
ax.set_yticks([])

# set tick font size
ax.tick_params(axis="x", labelsize=12)

# reduce border size
plt.tight_layout(pad=0)

# save out the pdf
plt.savefig(f"{results_directory}/final_tree_bootstrapped.pdf")
plt.close()
