#!/bin/bash
# concatenate_fastq.sh - this script will concatenate FASTQ sample parts into one whole FASTQ for each of the samples given and move to a new directory in results/
# this shell script must be run from the project root due to hardcoded paths for file moves and folder creation


# move into samples/ (if running outside project root 'cd data/' will fail and an error message is printed)
cd data/samples || \
{ echo "Samples directory not found, please ensure you are running this script from project root"; exit 1; }

fastq_folder=results/processed_FASTQ                               # set FASTQ folder name for ease

mkdir -p ../../$fastq_folder                                       # make processed fastq directory with folder name after moving two levels up and safe to re-run

for x in {A..D}; do                                                # loops for A, B, C, D (can be changed depending on downloaded file names)
    files=(sample${x}*)                                            # creates array called files of all files beginning with sample{letter of loop}
    
    echo "Concatenating sample${x} files..."                       # helps user see operations
    cat "${files[@]}" > "sample${x}_processed.FASTQ"               # concatenate full array of files to sample{letter of loop}_processed.FASTQ
    mv sample${x}_processed.FASTQ ../../$fastq_folder              # move the concatenated file to processed fastq directory in other part of repo
done

echo
echo "Processing complete. Find FASTA files in $folder"            # helps user know where to find processed FASTA files