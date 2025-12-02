# 13_view_tree.py -  generate and export phylogenetic trees from the .treefiles

import shutil
import os
from ete3 import Tree as Tree3, TreeStyle, NodeStyle, faces, AttrFace, TextFace
from ete4 import Tree as Tree4


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
# 2. tree view
##########

# create the tree by reading from the .treefile in results
t3 = Tree3(f"{treefile_directory}/partition.txt.treefile")

# set most recent common ancestor of selected outgroups (sharks) for re-rooting 
mrca_sharks = t3.get_common_ancestor("Etmopterus_spinax", "Heptranchias_perlo", "Etmopterus_pusillus")

# set outgroup to sharks 
t3.set_outgroup(mrca_sharks)


for leaf in t3.iter_leaves():
    if leaf.name.startswith("sample"):
        leaf.img_style["fgcolor"] = "firebrick"

#mrca_sharks.img_style["bgcolor"] = "#ddeeff50"

ts = TreeStyle()
ts.show_leaf_name = True
ts.show_branch_support = True
ts.branch_vertical_margin = 10
ts.scale = 5000

t3.show(tree_style=ts)

t3.render("tree.pdf")










# using ete4 to print a mini tree to the terminal at pipeline end because why not
t4 = Tree4(f"{treefile_directory}/partition.txt.treefile")
mrca_sharks = t4.common_ancestor("Etmopterus_spinax", "Heptranchias_perlo", "Etmopterus_pusillus")
t4.set_outgroup(mrca_sharks)
print(t4)

