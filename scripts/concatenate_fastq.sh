#!/bin/bash
# concatenate_fastq.sh - this script will concatenate FASTQ sample parts into one whole FASTQ for each of the samples given and move to a new directory in results/

# change directory into data/samples where samples are downloaded.
# if running direct from scripts/ directory cd data/ will fail, so an error message is printed
cd data/samples || \
{ echo "Samples directory not found, please ensure you are running this script from project root"; exit 1; }

folder=results/processed_FASTQ                                     # set folder name for ease

mkdir -p ../../$folder                                             # make processed fastq directory with folder name

for x in {A..D}; do                                                # loops for A, B, C, D (can be changed depending on downloaded file names)
    files=(sample${x}*)                                            # creates array called files of all files beginning with sample{letter of loop}
    echo "Processing sample${x} files..."                          # helps user see operations
    cat "${files[@]}" > "sample${x}_processed.FASTQ"               # concatenate full array of files to sample{letter of loop}_processed.FASTQ
    mv sample${x}_processed.FASTQ ../../$folder                    # move the concatenated file to processed fastq directory
done

echo
echo "Processing complete. Find concatenated samples in $folder"   # helps user know where to find processed samples