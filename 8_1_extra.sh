#!/bin/bash

# ad hoc additions
date -u

# Load modules
source /opt/miniforge3/etc/profile.d/conda.sh
conda activate humann4a

# split strat regrouped and renormed (but not renamed) genefamilies
cd ~/gcsfuse/mhra-ngs-dev-b9su_output/evette-humann-analysis
echo "######## Running split stratification of tables"
humann_split_stratified_table --input hmn4_genefamilies_regrp_renorm_cpm.tsv \
--output hmn4_genefamilies_regrp_renorm_cpm_stratification_out

# metaphlan4 combine profiles
cd ~/gcsfuse/mhra-ngs-dev-b9su_output/evette-humann-analysis
mkdir -p metaphlan_profiles_collated_out
find ~/gcsfuse/mhra-ngs-dev-b9su_output/evette-humann-analysis \
-type f -name "*metaphlan_profile.tsv" \
! -path "*/metaphlan_profiles_collated_out/*" \
-exec cp -n -v -t ~/gcsfuse/mhra-ngs-dev-b9su_output/evette-humann-analysis/metaphlan_profiles_collated_out/ {} +

merge_metaphlan_tables.py metaphlan_profiles_collated_out/*_profile.tsv > merged_abundance_table.tsv

echo "done!"
# ad hoc additions
date -u