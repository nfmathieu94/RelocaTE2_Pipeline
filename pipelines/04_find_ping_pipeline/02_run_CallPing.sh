#!/usr/bin/bash -l
#SBATCH -N 1 -n 32 --mem 40gb --out logs/CallPing.log --time 48:00:00

module load relocate2

ALL_RESULTS_DIR=results/relocate2_results_find_ping_raw

for dir in $ALL_RESULTS_DIR/*; do
  python2 pipelines/04_find_ping_pipeline/scripts/CallPing.py --input $dir --SNP  
done
