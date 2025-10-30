# Notes for project report

## PART 1 - FASTQ parts to single FASTA for each sample
### a) make sure all scripts are executable
```bash
chmod +x scripts/*
```

### b) script for preliminary checking of fastq format for each file provided.  
This is just as a preliminary check to see what the data look like without having to open each file. note - won't be helpful for a large number of files, but for this analysis it's fine as only a few:
```bash
#!/bin/bash
# check_fastq.sh - a checking script to see if each sample fastq follows fastq format
# each should have a label, raw sequence, + sign, and quality score line
# this shell script must be run from the project root due to hardcoded paths for file moves and folder creation


# move into samples/ (if running outside project root 'cd data/' will fail and an error message is printed)
pwd
cd data/samples || \
{ echo "Samples directory not found, please ensure you are running this script from project root"; exit 1; }


for fastq in *.FASTQ; do                                                             
    echo "$fastq file format:" >> fastq_format_check.txt           # for readability
    cut -c-15 "$fastq" | nl -ba  >> fastq_format_check.txt         # cuts out first 15 characters of every line, along with line numbering and -ba to catch all lines in file
    echo >> fastq_format_check.txt                                 # space for readability   
done

mv fastq_format_check.txt ../../results/                           # move file to results folder
echo
echo "FastQ check complete. Find output in results/"
```
Here i noticed some weird things: 
- sampleD part3 is not one word  
-  sampleB_part1.FASTQ has two headers  
- some have line counts not equal to 4 - a requirement for fastq  

Therefore I need to come up with a script which 1) cleans the fastq files to ensure they have 4 lines with header, sequence, '+', and quality score lines.  
I also want to concatenat all these fastq parts to their respective samples, so I will use a for loop which runs over each of the 4 sample names to clean and concatenate

### c) clean single-read fastq samples and concatenate into respective multi-read fastq files
```bash
./scripts/concatenate_fastq.sh
#!/bin/bash
# concatenate_fastq.sh - this script will clean sample parts and then concatenate parts into one whole FASTQ for each of the samples given and move to a new directory in results/
# this shell script must be run from the project root due to hardcoded paths for file moves and folder creation


# move into samples/ (if running outside project root 'cd data/' will fail and an error message is printed)
cd data/samples || \
{ echo "Samples directory not found, please ensure you are running this script from project root"; exit 1; }

fastq_folder=results/processed_FASTQ                                  # set FASTQ folder name for ease

mkdir -p ../../$fastq_folder                                          # make processed fastq directory with folder name after moving two levels up and safe to re-run

for x in {A..D}; do                                                   # loops for A, B, C, D (can be changed depending on downloaded file names)
    files=(sample${x}*)                                               # creates array called files of all files beginning with sample{letter of loop}
    
    echo "Concatenating sample${x} files..."                          # helps user see operations
    cat "${files[@]}" > "sample${x}_processed.FASTQ"                  # concatenate full array of files to sample{letter of loop}_processed.FASTQ
    
    sed -i 's/\([^\n]\)@/\1\n@/g' "sample${x}_processed.FASTQ"        # sed substitution to have headers on newline - if @ is preceded by a non-newline character, insert a newline character before '@' and the '@' itsef, globally 
    sed -i 's/^@\(.*\) /@\1_/g' "sample${x}_processed.FASTQ"           # sed substitution to remove header spaces - check headers (start with @) capture up to space and replace with capture followed by underscore, globally
    sed -i '/^$/d' "sample${x}_processed.FASTQ"                       # sed deletion - delete any empty lines in the multi-read fastq

    sed -i -e '$a\' "sample${x}_processed.FASTQ"                      # sed append - ensure last line of processed file ends in newline (not required for other parts as headers are made to have newline (above), but final line will not have a following header)

    # the following removes any duplicate lines following each other (which should never occur in fastq)
    temp="sample${x}_temp.FASTQ"                                      # make temporary file to write while loop to so it's not writing over input file
    previous=""                                                       # set previous = empty 
    while read -r line; do                                            #  loop over each line in file   
        if [[ "$line" != "$previous" ]]; then                         # if current line is not equal to the previous line...
            echo "$line"                                              # echo the line (into temp file)
        fi
        previous="$line"                                              # set 'previous' to the current line. the process will then repeat for the next line 
    done < "sample${x}_processed.FASTQ" > "$temp"                     # while loop reads from sample${x}_processed.FASTQ but outputs to temp file

    mv "$temp" "sample${x}_processed.FASTQ"                           # copy temp file over sample${x}_processed.FASTQ when finished
    mv sample${x}_processed.FASTQ ../../$fastq_folder                 # move the concatenated file to processed fastq directory in other part of repo
done

echo
echo "Processing complete. Find concatenated FASTQ files in $fastq_folder"  # helps user know where to find processed FASTA files
```
Here, in order to have an output with correctly formatted fastq I had to do some cleaning.  

I first concatenate each part-file for a sample into a processed concatenated fastq file, which includes all parts for that sample but un-cleaned. The loop then runs through a few `sed` commands which ensure:  
- **headers always fall on a new line**. i was having issues with the concatenated headers sometimes sticking to the end of the previous file's quality score, so this ensures any '@' (not a quality score character) will be preceded by a newline  
- **any spaces in headers are removed**. sampleD_part3 was mis labelled as 'sampleD part3' which could have caused issues with parsing downstream, so a sed substitution finds any spaces in the header, captures up to the space, then replaces the space with the capture followed by an underscrore, effectively 'sealing' the header label  
- **any empty lines are deleted**. fairly straight forward but fastq shouldn't have an empty line  
- **ensure the last line of file ends with newline**. this is only necessary for the final line which is not followed by a header '@' because of the sed for that already in place, but ensures it ends in a newline which is necessary for fastq  

Following those `sed` commands is a loop which i was stuck on for a while. sampleB_part1 had a duplicated header and i was stuck on how to fix this. ended up creating a while loop which reads each line in place and assigns that line to a variable. it then moves to the next line and compares against this variable. if they are not equal to each other then the 'next line' is echoed to a temporary file and then assignment moves down a line (so 'next line' becomes 'previous' and comparison continues). when the while loop has finished the file it saves the temp over the processed file (can't be saved over during while loop as would cause issues) then the processed file is moved to a new location.
