# Notes for project report

## PART 1 - FASTQ parts to single FASTA for each sample
### 0) make sure all scripts are executable
```bash
chmod +x scripts/*
```

### 1) script for preliminary checking of fastq format for each file provided.  
This is just as a preliminary check to see what the data look like without having to open each file. note - won't be helpful for a large number of files, but for this analysis it's fine as only a few:
Here i noticed some weird things: 
- sampleD part3 is not one word  
-  sampleB_part1.FASTQ has two headers  
- some have line counts not equal to 4 - a requirement for fastq  

Therefore I need to come up with a script which 1) cleans the fastq files to ensure they have 4 lines with header, sequence, '+', and quality score lines.  
I also want to concatenat all these fastq parts to their respective samples, so I will use a for loop which runs over each of the 4 sample names to clean and concatenate

### 2) clean single-read fastq samples and concatenate into respective multi-read fastq files
Here, in order to have an output with correctly formatted fastq I had to do some cleaning.  

I first concatenate each part-file for a sample into a processed concatenated fastq file, which includes all parts for that sample but un-cleaned. The loop then runs through a few `sed` commands which ensure:  
- **headers always fall on a new line**. i was having issues with the concatenated headers sometimes sticking to the end of the previous file's quality score, so this ensures any '@' (not a quality score character) will be preceded by a newline  
- **any spaces in headers are removed**. sampleD_part3 was mis labelled as 'sampleD part3' which could have caused issues with parsing downstream, so a sed substitution finds any spaces in the header, captures up to the space, then replaces the space with the capture followed by an underscrore, effectively 'sealing' the header label  
- **any empty lines are deleted**. fairly straight forward but fastq shouldn't have an empty line  
- **ensure the last line of file ends with newline**. this is only necessary for the final line which is not followed by a header '@' because of the sed for that already in place, but ensures it ends in a newline which is necessary for fastq  

Following those `sed` commands is a loop which i was stuck on for a while. sampleB_part1 had a duplicated header and i was stuck on how to fix this. ended up creating a while loop which reads each line in place and assigns that line to a variable. it then moves to the next line and compares against this variable. if they are not equal to each other then the 'next line' is echoed to a temporary file and then assignment moves down a line (so 'next line' becomes 'previous' and comparison continues). when the while loop has finished the file it saves the temp over the processed file (can't be saved over during while loop as would cause issues) then the processed file is moved to a new location.  

It's important to note why I am explicitly automating all of this. 1) it could be useful if given more data in the same format, but mainly 2) so that this is all reproducible. If i was to go in and manually edit the files I could come to the same processed fastq but with no evidence as to how I got there.


### 3) Covert fastq multi-read into multi-read FASTA with processing 
Includes a report on the raw fastq file using `fastqc`. 
 
The main bit to this uses `seqtk` to generate a) a raw fasta file with 3 reads (for each part) and b) a masked fasta file based on the quality scores from the fastq. Here the value of Q20 was set as a threshold, so any bases with a q score < 20 will be masked as an 'N' to reduce possible effects of false positives from BLAST etc. on low quality data. Q20 selected as it's a 99% confidence level for that base.

## Part 2 - BLAST searching
### 4) Take processed FASTA files and perform a BLAST search on them, gives tsv output and staxids
Of course, this produces a BLAST tsv dump for all parts (1,2 and 3) of each sample. Now I cannot assume that these parts are from the same loci, so actually i need to make sure i split up the outputs into the parts again before selecting distinct taxa and alignment, otherwise i could be trying to align random different areas (say sequences from part 1 and 3 of a sample), which would be messy.

### 5) Use `taxonkit` to get taxonomy for 20+ phylogenetically distinct outputs from each part of samples' blasts hits
n.b had to use taxonkit's dump to be able to use taxonkit: downloaded `taxdump.tar.gz` from https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/ and then added to home directory using `mkdir -p /.taxonkit`. then i gunzipped it and moved the 4 dump files into /.taxonkit. probably worth explaining this in readme or something:

```bash
# make folder
mkdir -p ~/.taxonkit

# download
wget ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz

# extract
tar -xzf taxdump.tar.gz

mv citations.dmp  gc.prt merged.dmp readme.txt delnodes.dmp gencode.dmp names.dmp division.dmp images.dmp nodes.dmp ~/.taxonkit/
```
Notes from week 7 intro to bioinformatics worksheet on how to filter: *You’re likely to uncover many BLAST hits and many homologs. When we’re trying to determine the taxonomic origin of a sequence it is good practise to include as many homologous sequences as possible. However, the databases we search against have become so large that it often becomes impractical to include all discovered homologs. Therefore, you are going to **filter your BLAST results on Percent Identity, E-value and Query Coverage** (see the grey “Filter results” box above your BLAST hits). Filter your results by specifying thresholds which you find appropriate for selecting homologous sequences for phylogenetic analysis and note them down in the following table:*  

In this script I split up the samples into parts 1, 2 and 3 again. This seems weird but it's actually helpful for QC as it lets me see if any of the parts are issues, rather than having it all together in one blast - it allows me to check phylogenetic consistency across sample parts.  

After splitting up, I do two things:  
- 1. I filter the blast hits in the 'part' blast tsvs by 95%+ pident and length >= 100bp. Anything returned from this is a strong likelihood for the actual species present in the sample. I noticed no hits from this for sample B and C, so can say there is **no-confidence on the species level** for these. Samples A and D did return confidence in species level from these blast hits, but notice that sampleD_part3 is human, so likely contaminated  
- 2. I then took the 'part' blast tsvs and sorted by a) staxid (gets same staxids together) and b) by e-values within each staxid. I then used seen to retrieve only the first of each staxid aka the lowest e value of each staxid. Note i did not filter by e value here as thisis for my phylogenetic tree, so I am less concerned about finding species level hits and instead want a broader range of accessions to build a tree later. This is where I selected my accessions for efetch in the next script. Note this is not me picking accessions for my tree, as i will ahave to do that manually by looking at the fastas and determining which are best for the alignment.


### 6) Running `efetch` to get fastas, then using sstart and send for each sequence from blast to trim the sequences to match the query
FIRST, I delete my sampleD_part3 files here. This is the end for them... (likely human contamination) so need to remember to mention in write up.  

This is essentially to create a candidate pool of sequences i might use in my alignment - note it's not selecting sequences etc. I need to do that manually. 

Also can't just use efetch as this will give me the whole genome/accession sequence which can be 10,000+ bases - so can use `seqtk sebseq` but this took some getting used to/understanding as i needed to create a `.bed` file with sstart-1 and send coordinates from the blast hot to line up properly to my original query sequence. here is a good explanation: https://www.reneshbedre.com/blog/seqtk-subseq.html .  

End up with fasta file of sequences which match the query sequence from the blast. These are all from phylogemetically distinct staxids as well from when I only selected top blast hit from each staxid in script 5.

#### note on reverse complementing with `seqtk`
... etc.

        # check if reverse complement necessary
        if [ "$sstart" -gt "$send" ]; then 

            # seqtk reverse complement function
            seqtk seq -r temp_trimmed.fasta >> 6_efetch_FASTA/"$part_name".fasta
        
        # case for forward strand = keep same
        else 
            cat temp_trimmed.fasta >> 6_efetch_FASTA/"$part_name".fasta
        fi

        rm temp_trimmed.fasta
        rm temp_full.fasta
        rm accession_start_end.bed

... etc.
```
Added this which will check if the reverse strand is used by blast hit and then if it is (ie sstart > send) it uses seqtk seq -r to do complement. I don't think any of my blast hits have sstart > send, but good to have just in case as that could be by luck. This, along with other coordinate check for seqtk, ensures all fasta sequences are in the same direction and orientation. 




