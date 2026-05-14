#!/bin/bash

inputdir=/mnt/data-disk/tmp_scratch/output/trimmed-data
outputdir=/mnt/data-disk/tmp_scratch/output/R1nR2-merged-trimmed-data

#inputdir=/home/AD/ehillman/Project_371/Clean_merged_371/
#outputdir=/home/AD/ehillman/Project_371/MergedR1nR2

mkdir -p $outputdir
cd $outputdir

echo "Merging files"

for f in ${inputdir}*combined_clean_R1.fastq.gz

do
prefix=${f/combined_clean_R1.fastq.gz/}
cat $f ${prefix}combined_clean_R2.fastq.gz > ${prefix}combined.fastq.gz
echo cat $f ${prefix}combined_clean_R2.fastq.gz into ${prefix}combined.fastq.gz
done

mv $inputdir/*combined.fastq.gz $outputdir

echo "All done"