#!/bin/bash
# concatenate_fastq.sh - clean and concatenate FASTQ parts into one file
# run from the project root

# move into samples/ 
cd data/samples || \
{ echo "Samples directory not found, please ensure you are running this script from project root"; exit 1; }

fastq_folder=results/2_FASTQ_processed                                  

mkdir -p ../../"$fastq_folder"   

# loops through samples A-D 
for letter in {A..D}; do     

    ##########
    # 1. concatenate fastq parts together:
    ##########

    # create array of all FASTQ files for sample                                            
    files=(sample${letter}*.FASTQ)                                               
    
    echo "Concatenating sample${letter} files..." 

    # concatenate full array of files to single file                         
    cat "${files[@]}" > "sample${letter}_processed.FASTQ"        

    ##########
    # 2. sed commands for text checking/replacing/deleting to keep fastq format:
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
    # 3. remove any duplicate lines following each other (which should never occur in fastq)
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
    mv sample${letter}_processed.FASTQ ../../"$fastq_folder"     
      
done

echo
echo "Processing complete. Find concatenated FASTQ files in $fastq_folder" 

cd ../../