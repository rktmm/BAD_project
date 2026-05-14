#!/bin/bash

input_dir=/mnt/data-disk/tmp_scratch/output/R1nR2-merged-trimmed-data
output_dir=/mnt/data-disk/tmp_scratch/output/batch-trimmed
BATCH_SIZE=27
COUNT=0
FOLDER_NUM=1

cd $input_dir || exit 1

shopt -s nullglob
# cd into input file location
for fastq in *.fastq.gz; do
    if [[ -d "$fastq" ]]; then
        continue
    fi
    # create folders for batches
    if (( COUNT % BATCH_SIZE == 0 )); then
        folder_name=$(printf "$output_dir-%03d" "$FOLDER_NUM")
        mkdir -p "$folder_name"
        ((FOLDER_NUM++)) # tracking number of folders generated
    fi

    # changed to copy (instead of mv) the file into the current folder
    cp -- "$fastq" "$folder_name/"
    ((COUNT++)) # tracking number of files processed
done
