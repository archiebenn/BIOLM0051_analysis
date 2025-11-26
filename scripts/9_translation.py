# 8_translation.py - a python script to translate the complete FASTA sequences from part 7 of analysis

import sys
import os
from Bio import SeqIO

# make results directory
os.makedirs("results/9_protein_FASTA", exist_ok=True)

# set directory where fasta files are kept
fasta_directory = "results/8_complete_FASTA/"



##########
# 1. function to generate all 3 translation frames, select frame with least stops
##########

def translate_all_frames(sequence):
    frames = []

    # count stop codons
    def count_stops(frame):
        return frame.count("*")

    for i in range(3):
        # translate each sequence with a shift of 0,1,2 bases from the start
        aa = sequence.seq[i:].translate(table=2)
        frames.append(str(aa))

    # pick frame with least stop codons to save
    best_protein = min(frames, key=count_stops)

    # return protein out of function env
    return best_protein

##########
# 2. access filenames in fasta directory and apply translation function
########## 

for filename in os.listdir(fasta_directory):
    # wipe each results file before appending
    with open(f"results/9_protein_FASTA/{filename}_prot.fasta", "w") as f:
        pass

    # use file name and SeqIO to open and then parse the fasta contents
    for sequence in SeqIO.parse(f"{fasta_directory}/{filename}", "fasta"):
        print(sequence.id, len(sequence.seq))

        # translate each sequence in fasta file and select frame with least stops
        protein = translate_all_frames(sequence)

        # write out > + sequence id + protein sequence to results folder
        with open(f"results/9_protein_FASTA/{filename}_prot.fasta", "a") as f:
            f.write(f">{sequence.id}\n{protein}\n")
