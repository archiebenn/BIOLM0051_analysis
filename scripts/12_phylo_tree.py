# 11_phylo_tree.py - to automate generating preliminary phylogenetic trees
import shutil
import os
import matplotlib.pyplot as plt
from Bio import Phylo

# remove output folder if it exists (if re-running with existing results/))
shutil.rmtree("../results/12_phylo_trees", ignore_errors=True)
os.makedirs("../results/12_tree_pdfs", exist_ok=True)

# set input directories
treefile_directory  = "../results/11_tree_files"
results_directory = "../results/12_phylo_trees"



# PART 1 IQ-TREE (.treefile is newick)
part1_tree = Phylo.read(tree, "newick")

part1_tree.root_with_outgroup(outgroup_as_str)

Phylo.draw(part1_tree)
plt.savefig(f"{results_directory}/part1_tree.pdf")
plt.close()

view_tree(f"{treefile_directory}/sampleC_part3_alignment.afa.treefile", "sampleC_part3")





# PART 2 IQ-TREE (.treefile is newick)
part2_tree = Phylo.read(treefile_path, "newick")

part2_tree.root_with_outgroup(outgroup_as_str)

Phylo.draw(part1_tree)
plt.savefig(f"{results_directory}/part3_tree.pdf")
plt.close()

view_tree(f"{treefile_directory}/sampleC_part3_alignment.afa.treefile", "sampleC_part3")





# PART 3 IQ-TREE (.treefile is newick)
part3_tree = Phylo.read(treefile_path, "newick")

part3_tree.root_with_outgroup(outgroup_as_str)

Phylo.draw(part3_tree)
plt.savefig(f"{results_directory}/part3_tree.pdf")
plt.close()

view_tree(f"{treefile_directory}/sampleC_part3_alignment.afa.treefile", "sampleC_part3")





# PART 1 IQ-TREE (.treefile is newick)
tree = Phylo.read(treefile_path, "newick")

tree.root_with_outgroup(outgroup_as_str)

Phylo.draw(tree)

plt.savefig(f"{results_directory}/{filename}_tree.pdf")

plt.close()

view_tree(f"{treefile_directory}/sampleC_part3_alignment.afa.treefile", "sampleC_part3")


