#!/bin/bash

# Script for Manipulating HumanN4 output tables

date -u

# Load modules
source /opt/miniforge3/etc/profile.d/conda.sh
conda activate humann4a
export HUMANN_CONFIG_FOLDER=/mnt/data-disk/tmp_scratch/database/humann4_db
humann_config --print

# for this particular analysis - it has been run in batches - therefore collate all tsv files into one folder
# file locations
#   ~/gcsfuse/mhra-ngs-dev-b9su_output/evette-humann-analysis/humann4_out-batch-00*/
#   containing and needisolating and combining the following files:
#   *_1_metaphlan_profile.tsv
#   *_2_genefamilies.tsv
#   *_3_reactions.tsv
#   *_4_pathabundance.tsv

cd ~/gcsfuse/mhra-ngs-dev-b9su_output/evette-humann-analysis
mkdir -p hmn4_collated_out
find ~/gcsfuse/mhra-ngs-dev-b9su_output/evette-humann-analysis \
-type f \( -name "*genefamilies.tsv" -o \
-name "*reactions.tsv" -o \
-name "*pathabundance.tsv" \) \
! -path "*/hmn4_collated_out/*" \
-exec cp -n -v -t ~/gcsfuse/mhra-ngs-dev-b9su_output/evette-humann-analysis/hmn4_collated_out/ {} +
# all files in /hmn4_collated_out

# combine sample tables for gene families, reactions, and pathway abundance - step 1
echo "######## Running join tables"
humann_join_tables --input hmn4_collated_out \
--output hmn4_genefamilies.tsv --file_name genefamilies
humann_join_tables --input hmn4_collated_out \
--output hmn4_reactions.tsv --file_name reactions
humann_join_tables --input hmn4_collated_out \
--output hmn4_pathabundance.tsv --file_name pathabundance

# regroup for genefamilies - step 2
echo "######## Running gene families regroup tables"
humann_regroup_table --input hmn4_genefamilies.tsv \
--output hmn4_genefamilies_regrp.tsv \
--groups uniref90_ko

# re-normalise tables (with cpm) for gene families after regrouping - move below regroup - only req for genefamilies
echo "######## Running renormalisation of tables"
humann_renorm_table --input hmn4_genefamilies_regrp.tsv \
--units cpm \
--output hmn4_genefamilies_regrp_renorm_cpm.tsv

# Rename
echo "######## Running rename tables"
humann_rename_table --input hmn4_genefamilies_regrp_renorm_cpm.tsv \
--output hmn4_genefamilies_regrp_renorm_cpm_ko_named.tsv \
--names kegg-orthology
humann_rename_table --input hmn4_reactions.tsv \
--output hmn4_reactions_metcy_named.tsv \
--names metacyc-rxn
humann_rename_table --input hmn4_pathabundance.tsv \
--output hmn4_pathabundance_metcy_named.tsv \
--names metacyc-pwy

# split stratified by bugs - move to end
echo "######## Running split stratification of tables"
humann_split_stratified_table --input hmn4_genefamilies_regrp_renorm_cpm_ko_named.tsv \
--output hmn4_genefamilies_regrp_renorm_cpm_ko_named_stratification_out
humann_split_stratified_table --input hmn4_reactions_metcy_named.tsv \
--output hmn4_reactions_metcy_named_stratification_out
humann_split_stratified_table --input hmn4_pathabundance_metcy_named.tsv \
--output hmn4_pathabundance_metcy_named_stratification_out

date -u
echo "done!"
