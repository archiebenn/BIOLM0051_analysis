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
# 1. function to return the longest translated orf between stops of each sequence
##########


def find_orf(sequence):

    # inititate list to add translated frames to
    frames = []

    # repeat for each frame (in one direction)
    for i in range(3):
        # translate each sequence with a shift of 0,1,2 bases from the start
        # using codon table 2 for vertebrate mitochondrion translation
        aa = sequence.seq[i:].translate(table=2, to_stop = False)
        frames.append(str(aa))

    # inner function to count longest orf length, splitting protein sequence by */STOP
    def longest_orf(prot_sequence):
        return max(len(orf) for orf in prot_sequence.split("*"))

    # pick frame with longest orf:
    best_protein_frame = max(frames, key=longest_orf)

    # select best orf out of best protein frame
    best_orf = max(best_protein_frame.split("*"), key=len)

    # return out of function environment
    return best_orf



##########
# 2. function to return translated frame with least stop codons
##########

def find_frame(sequence):

    # initiate list to add translated frames to
    frames = []

    # repeat for each frame (in one direction)
    for i in range(3):

        # translate each sequence with a shift of 0,1,2 bases from the start
        # using codon table 2 for vertebrate mitochondrion translation
        aa = sequence.seq[i:].translate(table=2, to_stop = False)
        frames.append(aa)

    # inner function to count stop codons in protein sequence
    def count_stops(prot_sequence):
        return prot_sequence.count("*")
    
    # pick frame with least stops
    best_frame = min(frames, key=count_stops)

    # return best frame out of function env
    return best_frame



##########
# 3. access filenames in fasta directory and apply translation function
##########

for filename in os.listdir(fasta_directory):
    # wipe each results file before appending
    with open(f"results/10_protein_FASTA/{filename}_prot.fasta", "w") as f:
        pass

    # use file name and SeqIO to open and then parse the fasta contents
    for sequence in SeqIO.parse(f"{fasta_directory}/{filename}", "fasta"):
        print(sequence.id, len(sequence.seq))

        
        protein_seq = find_orf(sequence)


        # write out > + sequence id + protein sequence to results folder
        with open(f"results/10_protein_FASTA/{filename}_prot.fasta", "a") as f:
            f.write(f">{sequence.id}\n{protein_seq}\n")


