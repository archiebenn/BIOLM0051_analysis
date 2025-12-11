# Academic Integrity/AI use declaration 1935263
AI was used during this submission in accordance with the University of Bristol's 'Category 3' AI use. This consists of the following:  

```
Category 3 Selective – AI tools can be used in limited and clearly defined ways

1.     Initial Research: you can use AI as a mechanism for researching and exploring relevant literature and ideas. However, you should then read suggested sources rather than cite directly from the AI and the responsibility for accuracy remains with you.

2.     Spelling and grammar checkers: you can use spelling and grammar checkers in this assignment, although they should be used to correct rather than conduct substantial re-writes.

3.     Suggesting structures: AI can suggest templates for you to consider (e.g. essay plan or report structure).

4.     Substitute for coding Q&A websites (e.g. Stack Exchange). You may use AI to request explanations of functions, clarify concepts, or explore how particular libraries work. You must not use AI to write or rewrite large blocks of code for you. The code you submit must reflect your own work, understanding, and decision-making. Copy-pasting AI-generated scripts into your submission is not permitted.
```

**AI tools (chatGPT) were used in the following ways for this submission:**  
- Clarifying pipeline "run time" code 
- Understanding `pipefail` for pipeline safety on each script
- Understanding use of `while read -r line; do` to loop over each line in a file in comparison of current line to previous line in FASTQ files (script 2)
- Learning what external tools exist and reading examples (before reading official documentation online, where available): `seqtk`,`taxonkit`, `efetch`,`seqkit`, `catfasta2phyml`, `trimal`, `iqtree3`, `ete3`, `ete4`, `needle`  
- Learning how to use `basename` to extract names within loops  
- Learning how to implement a BLAST log to document time and `blastn` version used (script 4)
- Understanding use of `!seen[$x]++` to skip non-unique variables (script 5)
- Understanding use of `while IFS=$\t read x y z; do` to extract values from a tsv and settting as new variable names (script 7)
- Understanding reference sequence direction orientation using BLAST `sstart` and `ssend` values (script 7)
- Understanding the use of .bed genomic coordinates and `seqtk subseq` to trim regions as well as `seqtk seq -r` to reverse-complement sequence if reference origininates from the reverse strand  (script 7)
- Learning how to skip a file if it does not exist in a directory `[[ ! -f directory/file ]] && continue`  (script 9)
- Understaning `shutil` and `os` modules in python to create and remove directories from within python script (script 10)  
- Clarifying use of inner function to return longets orf out of orfs split by stop/* (script 10)
- Learning how to use `f.write` to add '>' to protein seq fasta file (script 10)
- Learning about partitioned supermatrices and their use in this pipeline to concatenate the alignment fasta files using `castfasta2phyml` (script 11)  
- Learning about bootstrap replicates for confidence values and how to apply these with `iqtree3` (script 12)
- Finding out how to change tip labels to italicised times new roman, and recolouring 'sampleX' tips with loop: `for leaf in t3.iter_leaves():` in `ete3` (script 13)  
- Finding out how to hide nodes on final tree in `ete3`  (script 13)  
- Providing a rough structure for my discussion section (report)
- Understanding use of `tcolorbox` in LaTeX to put green line around abstract  (report)  
- Learning about TeXShade within LaTeX as a tool for nice alignment figures and annotations (report)  

All scripts and text submitted are my own work - AI was used only for conceptual clarification.
