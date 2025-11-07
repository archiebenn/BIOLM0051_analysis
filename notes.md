# Notes for project report

## PART 1 - FASTQ parts to single FASTA for each sample
### 0) make sure all scripts are executable
```bash
chmod +x scripts/*
```

### 1) script for preliminary checking of fastq format for each file provided.  
This is just as a preliminary check to see what the data look like without having to open each file. note - won't be helpful for a large number of files, but for this analysis it's fine as only a few:
```bash
#!/bin/bash
# check_fastq.sh - a checking script to see if each sample fastq follows fastq format
# this shell script must be run from the project root due to hardcoded paths for file moves and folder creation

# move into samples/ (if running outside project root 'cd data/' will fail and an error message is printed)
cd data/samples || \
{ echo "Samples directory not found, please ensure you are running this script from project root"; exit 1; }

# for loop to catch every FASTQ file
for fastq in *.FASTQ; do  

    # identifier for readability in text file
    echo "$fastq file format:" >> fastq_format_check.txt         

    # cut out first 15 characters of every line, along with line numbering and -ba to catch all lines in the FASTQ file:
    cut -c-15 "$fastq" | nl -ba  >> fastq_format_check.txt 

    # space for readability         
    echo >> fastq_format_check.txt                                   
done

# move file to results folder:
mv fastq_format_check.txt ../../results/                           
echo
echo "FastQ check complete. Find output in results/"
```
Here i noticed some weird things: 
- sampleD part3 is not one word  
-  sampleB_part1.FASTQ has two headers  
- some have line counts not equal to 4 - a requirement for fastq  

Therefore I need to come up with a script which 1) cleans the fastq files to ensure they have 4 lines with header, sequence, '+', and quality score lines.  
I also want to concatenat all these fastq parts to their respective samples, so I will use a for loop which runs over each of the 4 sample names to clean and concatenate

### 2) clean single-read fastq samples and concatenate into respective multi-read fastq files
```bash
#!/bin/bash
# concatenate_fastq.sh - this script will clean sample parts and then concatenate parts into one whole FASTQ for each of the samples given and move to a new directory in results/
# this shell script must be run from the project root due to hardcoded paths for file moves and folder creation

# move into samples/ (if running outside project root 'cd data/' will fail and an error message is printed)
cd data/samples || \
{ echo "Samples directory not found, please ensure you are running this script from project root"; exit 1; }

# set FASTQ folder name for ease
fastq_folder=results/processed_FASTQ                                  

# make processed fastq directory with folder name after moving two levels up and safe to re-run
mkdir -p ../../$fastq_folder                                         

# loops for A, B, C, D (can be changed depending on downloaded file names)
for x in {A..D}; do      

    # creates array called files of all FASTQ files beginning with sample{letter of loop}                                             
    files=(sample${x}*.FASTQ)                                               
    
    echo "Concatenating sample${x} files..." 

    # concatenate full array of files to sample{letter of loop}_processed.FASTQ                         
    cat "${files[@]}" > "sample${x}_processed.FASTQ"                  
    
    # sed substitution to have headers on newline - if @ is preceded by a non-newline character, insert a newline character before '@' and the '@' itsef, globally:
    sed -i 's/\([^\n]\)@/\1\n@/g' "sample${x}_processed.FASTQ"    

    # sed substitution to remove header spaces - check headers (lines that start with @) capture up to space and replace with capture followed by underscore, globally:
    sed -i 's/^@\(.*\) /@\1_/g' "sample${x}_processed.FASTQ"     

    # sed deletion - delete any empty lines in the multi-read fastq:      
    sed -i '/^$/d' "sample${x}_processed.FASTQ"                      

    # sed append - ensure last line of processed file ends in newline (not required for other parts as headers are made to have newline (above), but final line will not have a following header)
    sed -i -e '$a\' "sample${x}_processed.FASTQ"                      

    # the following removes any duplicate lines following each other (which should never occur in fastq)
    # make temporary file to write while loop to so it's not writing over input file:
    temp="sample${x}_temp.FASTQ"                                      
    previous=""

    #  loop over each line in file                                                        
    while read -r line; do 

        # comparison of current line to previous line. if not equal then...                                             
        if [[ "$line" != "$previous" ]]; then  

            # ...echo the line (into temp file)                       
            echo "$line"                                              
        fi

        # set 'previous' to the current line. the process will then repeat for the next line
        previous="$line"                    

    # while loop reads from sample${x}_processed.FASTQ but outputs to temp file                          
    done < "sample${x}_processed.FASTQ" > "$temp"                     

    # copy temp file over sample${x}_processed.FASTQ when finished 
    mv "$temp" "sample${x}_processed.FASTQ"

    # move the concatenated file to processed fastq directory in other part of repo                           
    mv sample${x}_processed.FASTQ ../../$fastq_folder                 
done

echo

# helps user know where to find processed FASTA files
echo "Processing complete. Find concatenated FASTQ files in $fastq_folder" 
```
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
```bash
#!/bin/bash
# fastq_to_fasta.sh - using seqtk for quality control with phred algorithm and to convert multi-line fastq to fasta sequence
# this shell script must be run from the project root due to hardcoded paths for file moves 

# move into results/ (if running outside project root 'cd results/' will fail and an error message is printed)
cd results || \
{ echo "Results directory not found, please ensure you are running this script from project root"; exit 1; }

# make directories for raw FASTA and trimmed FASTA sequences
mkdir -p FASTQC_reports
mkdir -p FASTA_raw
mkdir -p FASTA_processed

for fastq in FASTQ_processed/*.FASTQ; do

    # extract base name of file
    name=$(basename "$fastq" _processed.FASTQ)

    # run fastqc for a report on the merged fastq file (reports not on github)
    fastqc "$fastq" -o FASTQC_reports/

    # seqtk directly to raw fasta conversion (no trimming) and remove any spaces, then save
    seqtk seq -a "$fastq" | tr -d ' ' > "FASTA_raw/${name}_raw.fasta"

    # convert seqtk to mask bases to 'N' if lower than Q20 (threshold at 99%+ confidence), then convert to fasta and save
    seqtk seq -q20 -n N "$fastq" | seqtk seq -a - | tr -d ' ' > "FASTA_processed/${name}_Q20.fasta"

done
echo

echo "Find fastqc reports in results/FASTQC_reports"  
echo "Find raw FASTA outputs in results/FASTA_raw and masked outputs in results/FASTA_masked"

cd ../
```
 
The main bit to this uses `seqtk` to generate a) a raw fasta file with 3 reads (for each part) and b) a masked fasta file based on the quality scores from the fastq. Here the value of Q20 was set as a threshold, so any bases with a q score < 20 will be masked as an 'N' to reduce possible effects of false positives from BLAST etc. on low quality data. Q20 selected as it's a 99% confidence level for that base.

## Part 2 - BLAST searching
### 4) Take processed FASTA files and perform a BLAST search on them, gives tsv output and staxids
```bash
#!/bin/bash

# move into results/ (if running outside project root 'cd data/' will fail and an error message is printed)
cd results || \
{ echo "Samples directory not found, please ensure you are running this script from project root"; exit 1; }

# make blast results folder
mkdir -p 4_blast_outputs

for fasta in 3_FASTA_processed/*.fasta; do

    # extract file base name
    name=$(basename "$fasta" _q20.fasta)

    echo
    echo "Carrying out a BLAST search on "$fasta"..."

    # run blastn nucleotide search remotely and save hits as a .tsv file with headers/comments (7) (can be adapted for running on hpc with local db)
    blastn -query "$fasta" -db nt -out "$name"_blast.tsv -outfmt "6 qseqid sacc staxids pident length mismatch gapopen qstart qend sstart send evalue bitscore" -remote

    # create a blast log to detail run date/version/input etc. (even if version locked in micromamba env)
    {
        echo "=== BLAST log for "$name"_blast.tsv ==="
        date
        blastn -version

        echo "Command used:"
        echo "blastn -query "$fasta" -db nt -out "$name"_blast.tsv -outfmt \"6 qseqid sacc staxids pident length mismatch gapopen qstart qend sstart send evalue bitscore\" -remote"
        
    } > "$name"_blast.log

    # move both into blast folder
    mv "$name"_blast.tsv "$name"_blast.log 4_blast_outputs/

done

echo "BLAST searches complete. Find blast tsvs and log files in results/4_blast_outputs/"
cd ..
```

### 5) Use `taxonkit` to get taxonomy for 20 phylogenetically distinct outputs from blast tsv
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
