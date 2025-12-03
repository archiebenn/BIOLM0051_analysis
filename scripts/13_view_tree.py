# 13_view_tree.py -  generate and export phylogenetic trees from the .treefiles

import shutil
import os
from ete3 import Tree as Tree3, TreeStyle, NodeStyle, TextFace
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
mrca_sharks = t3.get_common_ancestor(
    "Etmopterus_spinax", "Heptranchias_perlo", "Etmopterus_pusillus"
)

# set outgroup to sharks (re-root here)
t3.set_outgroup(mrca_sharks)


##########
# 3. tree aesthetics
##########
ns = NodeStyle()
ts = TreeStyle()

# hide the leaf/tip name as will change the font later
ts.show_leaf_name = False

# show bootstrap values
ts.show_branch_support = True

# allow some spacing vertically between branches
ts.branch_vertical_margin = 2

# show a scale bar
ts.show_scale = True

# scale in the x axis to fit the page
ts.scale = 5000


# iterate over the leaves/tips to change their appearance on the tree
for leaf in t3.iter_leaves():
    # set each tip label to times new roman (consisten with report) and size 11 font
    lf = TextFace(
        leaf.name,
        fsize=11,
        ftype="Times",
    )

    # for clarity set sample tips to firebrick red
    if leaf.name.startswith("sample"):
        lf.fgcolor = "firebrick"

    # increase margin from tip labbel to the branch end
    lf.margin_left = 6

    # apply each label to the tree
    leaf.add_face(lf, column=0)

# set node size = 0
ns["size"] = 0

# apply node size across all nodes in tree to hide them
for n in t3.traverse():
    n.set_style(ns)
    
def make_branches_bigger(node, new_size):
    node.img_style["hz_line_width"] = new_size # Change the horizotal lines stroke size
    node.img_style["vt_line_width"] = new_size # Change the vertical lines stroke size
    for c in node.children:
        make_branches_bigger(c, new_size)

# save out the tree yo a pdf in results/
t3.render(f"{results_directory}/final_tree.pdf", tree_style=ts)


# using ete4 to print a mini tree to the terminal at pipeline end because why not
t4 = Tree4(f"{treefile_directory}/partition.txt.treefile")
mrca_sharks = t4.common_ancestor(
    "Etmopterus_spinax", "Heptranchias_perlo", "Etmopterus_pusillus"
)
t4.set_outgroup(mrca_sharks)
print()
print(t4)
print()
