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