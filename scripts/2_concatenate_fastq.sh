#!/bin/bash
# concatenate_fastq.sh - clean and concatenate FASTQ parts into one file
# run from the project root

##########
# setup  and error handling
##########

# strict mode - exit on errors and pipeline failures
set -eo pipefail

# move into samples/ and exit if not in root
cd data/ || \
{ echo "Data directory not found, please ensure you are running this script from project root"; exit 1; }

fastq_folder=results/2_FASTQ_processed                                  

# remove output folder if it exists (if re-running with existing results/)
rm -rf ../../results/2_FASTQ_processed

# create ouput folder
mkdir -p ../../results/2_FASTQ_processed   

# set input folder to read from
input_dir=samples/samples

# check that the input folder from previous script contains files for the loop (and silences internal errors)
ls "$input_dir"/*.FASTQ >/dev/null 2>&1 || \
{ echo "[ISSUE] No files found in $input_dir. Previous script may have failed. Exiting script."; exit 1; }



##########
# main script loop to concatenate FASTQ:
##########

# loop through samples according to letter
for letter in {A..D}; do     

    # create array of all FASTQ files for sample                                            
    files=(sample"${letter}"*.FASTQ)                                               
    
    echo "Concatenating sample${letter} files..." 

    # concatenate full array of files to single file                         
    cat "${files[@]}" > "sample${letter}_processed.FASTQ"        

    ##########
    # sed commands for text checking/replacing/deleting to keep fastq format:
    ##########         

    # substitution to ensure @ is always on a newline globally
    sed -i 's/\([^\n]\)@/\1\n@/g' "sample${letter}_processed.FASTQ"    

    # substitution to remove header space
    sed -i '/^@/s/ /_/g' "sample${letter}_processed.FASTQ"     

    # delete any empty lines in the multi-read fastq:      
    sed -i '/^$/d' "sample${letter}_processed.FASTQ"                      

    # ensure final line in file is a newline
    sed -i '$a\' "sample${letter}_processed.FASTQ"   

    # no underscore after 'part' in headers for consistency
    sed -i 's/part_/part/g' "sample${letter}_processed.FASTQ"               

    ##########
    # remove any duplicate lines following each other (which should never occur in fastq)
    ##########

    # temporary file to write loop to so it's not writing over input file:
    temp="sample${letter}_temp.FASTQ"                                      
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
    done < "sample${letter}_processed.FASTQ" > "$temp"                     

    # copy temp file over sample${x}_processed.FASTQ when finished 
    mv "$temp" "sample${letter}_processed.FASTQ"

    # move the concatenated file to processed fastq directory in other part of repo                           
    mv "sample${letter}_processed.FASTQ" ../results/2_FASTQ_processed     
      
done

cd ../..