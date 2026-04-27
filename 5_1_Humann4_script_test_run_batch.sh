#!/bin/bash

# Script for functional profiling of paired-end reads using humann4

# ensure bucket is mounted

# set original location of db
# set original location of fastq
# set tmp locations
## tmp location of db
## tmp location of fastq

# worflow -> find raw data bucket -> copy raw data to internal tmp 
# Navigate to folder containing fastq files
cd /mnt/data-disk/tmp_scratch/output/batch-trimmed-data

mkdir -p /mnt/data-disk/tmp_scratch/output/humann4_output-batch

# Load modules
source /opt/miniforge3/etc/profile.d/conda.sh
conda activate humann4a

# If you already have the MetaPhlAn database downloaded and built, you can execute HUMAnN using metaphlan_options set with e.g. "--index mpa_v30_CHOCOPhlAn_201901" and this will skip the check for a new version.
# Run HUMAnN4
for Reads in *.fastq.gz
  do
    humann --input ${Reads} \
      --output /mnt/data-disk/tmp_scratch/output/humann4_output-batch \
      --nucleotide-database /mnt/data-disk/tmp_scratch/database/humann4_db/chocophlan \
      --protein-database /mnt/data-disk/tmp_scratch/database/humann4_db/uniref \
      --metaphlan-options "-t rel_ab_w_read_stats --bowtie2db /mnt/data-disk/tmp_scratch/database/metaphlan_db --index mpa_vOct22_CHOCOPhlAnSGB_202403" \
      --threads 16 \
      --memory-use maximum
done

conda deactivate

echo "All done"