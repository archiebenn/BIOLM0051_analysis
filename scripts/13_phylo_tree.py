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

# resize the plot to fit a4 landscape
fig = plt.figure(figsize=(12, 10))
ax = fig.add_subplot(1, 1, 1)


# flip branches in y axis
full_tree.ladderize() 

# draw the tree
Phylo.draw(full_tree, axes = ax, do_show = False)

bootstrap_values = []

for t in ax.texts:
    s = t.get_text()

    try:
        float(s)
        bootstrap_values.append(t)
    except ValueError:
        pass
# create a list of bootstrap values to move (on final)
selected_y_bootstraps = (100,57,96,98,50,67)
selected_x_bootstraps = (99,100,43,85,37,75,29,76,67,71,53,91)


for text in ax.texts:

    # retrieve the value of the text e.g (Text(0.0980949282, 21, ' Balaena_mysticetus') becomes Balaena_mysticetus
    value = text.get_text()

    try:
        float(value)
    
    except ValueError:
        pass
        #x, y = value.get_position()
        #value.set_position((x - 0.00, y - 10))


for bs in selected_x_bootstraps:

    for text in ax.texts:

        value = text.get_text()

        try:
            int(value)
        
        except ValueError:
            pass

        print(type)

        if bs == value: 

            print(value)

            x, y = value.get_position()

            print(x,y)

            value.set_position((x - 1, y - 0))





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
plt.xlabel("Substitutions per site", labelpad=12, fontsize = 16)
plt.ylabel("")

# remove y ticks
ax.set_yticks([])

# set tick font size
ax.tick_params(axis = 'x', labelsize = 12)

# reduce border size
plt.tight_layout(pad=0)

# save out the pdf
plt.savefig(f"{results_directory}/samples_tree.pdf")
plt.close()
