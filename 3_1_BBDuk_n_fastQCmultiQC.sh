#!/bin/bash

#S-WATCH -n 32 
#S-WATCH --memo-per-cps 16G
# RM: these were kept just to see what slurm parameters were picked last time
# RM: made as little change as possible to the script to ensure I replicate previous analysis as close as possible

# This script will clean the concatenate R1 and R2 files then run FastQC and MultiQC on all sequencing files for ALL the sequencing project ($inputdir) and output the final results into the $outputdir.

# Set your input directory to the concatenated files containing ALL sequencing projects you wish to analyse. The output directory to name of the output directory you want, and adapters to where the adapters.fa file for BBDUK is. 

inputdir=/mnt/data-disk/tmp_scratch/input
outputdir=/mnt/data-disk/tmp_scratch/output/trimmed-data
inputdir1=/mnt/data-disk/tmp_scratch/output/trimmed-data/*fastq.gz
outputdir1=/mnt/data-disk/tmp_scratch/output/trimmed-fastqc
inputdir2=/mnt/data-disk/tmp_scratch/output/trimmed-fastqc
outputdir2=/mnt/data-disk/tmp_scratch/output/trimmed-multiqc

#adapters=/home/AD/ehillman/.conda/envs/bbtools/bbtools/lib/resources/adapters.fa
#adapters=/home/AD/ehillman/adapters.fa

mkdir -p $outputdir
cd $inputdir


echo "You are running QC on all sequencing files in $inputdir. Outputs will be put into the folder $outputdir"

echo "Quality control..."   

# conda3 activate
source /opt/miniforge3/etc/profile.d/conda.sh 
conda activate bbtools
# source activate bbtools

# BBDuk will: 

Ordered=t #Set to true to output reads in same order as input 
Ktrim=r #once a reference kmer is matched in a read, that kmer and all the bases to the right will be trimmed
K=21 #specifies the kmer size
Mink=10 #"mink" allows it to use shorter kmers at the ends of the read 
Hdist=2 #number of permitted missmatches
Qtrim=r #quality trim on right
Trimq=20 #1 in 100 or 99% 
Minlen=50 #throw away reads shorter than 100bp after trimming
Maq=10 #This will discard reads with average quality below 20 ie 99%

shopt -s nullglob
for Prefix in  `ls -1 *_R1.fastq.gz | sed 's/_R1.fastq.gz//'` ; do
    bbduk.sh -Xmx20g in1=$Prefix\_R1.fastq.gz in2=$Prefix\_R2.fastq.gz out1=$Prefix\_clean_R1.fastq.gz out2=$Prefix\_clean_R2.fastq.gz ref=adapters,phix ordered=$Ordered ktrim=$Ktrim k=$K mink=$Mink hdist=$Hdist tpe tbo qtrim=$Qtrim trimq=$Trimq minlen=$Minlen maq=$Maq	
done
# adjusted -XMx to 20g from 128g (my mp4 image VM on GCP only has ~70g of memory)
conda deactivate 

mv $inputdir/*clean_R1.fastq.gz $outputdir
mv $inputdir/*clean_R2.fastq.gz $outputdir

echo "Running fastQC and MultiQC"
conda activate fastqc-multiqc

# FastQC
echo "About to start running FastQC"
mkdir -p $outputdir1
fastqc $inputdir1 -o $outputdir1 --threads 16

# MultiQC
echo "About to start running MultiQC"
mkdir -p $outputdir2

multiqc $inputdir2 -o $outputdir2

conda deactivate 

cd $outputdir2
mkdir -p /home/ryan_mate_nibsc_org/gcsfuse/mhra-ngs-dev-b9su_output/evette-humann-analysis/trimmed-fastqc
cp -r . /home/ryan_mate_nibsc_org/gcsfuse/mhra-ngs-dev-b9su_output/evette-humann-analysis/fastqc/

echo "All done"