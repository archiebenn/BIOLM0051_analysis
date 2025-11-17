# 8_translation.py - a python script to translate the complete FASTA sequences from part 7 of analysis

from Bio.Seq import Seq
from Bio import SeqIO
import argparse
import os

# set directory where fasta files are kept
fasta_directory = "../results/7_complete_FASTA/"

# function to generate all 3 translation frames
def translate_all_frames(sequence):

    # initiate protein list
    proteins = []

    for i in range(3):

        # translate each sequence with a shift of 0,1,2 bases from the start
        aa = sequence.seq[i:].translate(table=2)

        # append aa sequence to list
        proteins.append(aa)

    return proteins
    


    

# access filenames in fasta directory
for file in os.listdir(fasta_directory): 
    
    # use file name and SeqIO to open and then parse the fasta contents
    for sequence in SeqIO.parse(f"{fasta_directory}/{file}", "fasta"):

        proteins_list = translate_all_frames(sequence)
        print(proteins_list)
        print()



### TO do - need to filter for correct frame (lowest *s?)