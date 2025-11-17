# 8_translation.py - a python script to translate the complete FASTA sequences from part 7 of analysis

from Bio.Seq import Seq
from Bio import SeqIO
import argparse
import os

# set directory where files are kept
fasta_directory = "../results/7_complete_FASTA/"

# access filenames in fasta directory
for file in os.listdir(fasta_directory): 
    
    # use file name and SeqIO to open and then parse the fasta contents
    for sequence in SeqIO.parse(f"{fasta_directory}/{file}", "fasta"):
        print(sequence.id)

