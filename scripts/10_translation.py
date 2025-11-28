# 10_translation.py - a python script to translate the complete FASTA sequences from part 9

import shutil
import os
from Bio import SeqIO

# remove output folder if it exists (if re-running with existing results/))
shutil.rmtree("results/10_protein_FASTA", ignore_errors=True)

# make results directory
os.makedirs("results/10_protein_FASTA", exist_ok=True)

# set directory where fasta files are kept
fasta_directory = "results/9_complete_FASTA/"


##########
# 1. function to translate the nt sequence, and return the longest orf between stops of each sequence
##########


def find_orf(sequence):
    frames = []

    # repeat for each frame (in one direction)
    for i in range(3):
        # translate each sequence with a shift of 0,1,2 bases from the start
        aa = sequence.seq[i:].translate(table=2)
        frames.append(str(aa))

    # inner function to choose longest orf, splitting sequence by */STOP
    def longest_orf(prot_sequence):
        return max(len(orf) for orf in prot_sequence.split("*"))

    # pick frame with longest orf:
    best_protein_frame = max(frames, key=longest_orf)

    # select best orf out of best protein frame
    best_orf = max(best_protein_frame.split("*"), key=len)

    # return out of function environment
    return best_orf




#### TODO
# def find_least_stops(COMPLETE!!)
                     



##########
# 2. access filenames in fasta directory and apply translation function
##########

for filename in os.listdir(fasta_directory):
    # wipe each results file before appending
    with open(f"results/10_protein_FASTA/{filename}_prot.fasta", "w") as f:
        pass

    # use file name and SeqIO to open and then parse the fasta contents
    for sequence in SeqIO.parse(f"{fasta_directory}/{filename}", "fasta"):
        print(sequence.id, len(sequence.seq))



        ### ######## TODO
        # if sequence.id == outgroup names, apply just minimum stop function 
        # else apply find_orf (can't use get orf on a full genome as would be unlikely to match same gene/orf as in refs and samples)





        # translate each sequence in fasta file and select frame with least stops
        protein = find_orf(sequence)

        # write out > + sequence id + protein sequence to results folder
        with open(f"results/10_protein_FASTA/{filename}_prot.fasta", "a") as f:
            f.write(f">{sequence.id}\n{protein}\n")
