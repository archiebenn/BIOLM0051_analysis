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
    previous=""                                                       # starts previous = empty string
    while read -r line; do                                            #  loop over each line in file   
        if [[ "$line" != "$previous" ]]; then                         # if line is not equal to the previous line...
            echo "$line"                                              # echo the line
        fi
        previous="$line"                                              # set previous to that line (so will run through and change each previous to the current line and repeat through the file)
    done < "sample${x}_processed.FASTQ" > "$temp"                     # while loop reads from sample${x}_processed.FASTQ but outputs to temp file

    mv "$temp" "sample${x}_processed.FASTQ"                           # copy temp file over sample${x}_processed.FASTQ
    mv sample${x}_processed.FASTQ ../../$fastq_folder                 # move the concatenated file to processed fastq directory in other part of repo
done

echo
echo "Processing complete. Find concatenated FASTQ files in $fastq_folder"  # helps user know where to find processed FASTA files