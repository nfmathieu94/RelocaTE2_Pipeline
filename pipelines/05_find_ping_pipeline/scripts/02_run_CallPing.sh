#!/usr/bin/bash -l
#SBATCH -N 1 -n 32 --mem 40gb --out logs/CallPing.log --time 48:00:00

module load relocate2

all_results_dir=relocate2_results_raw_5.11.25_characterizer_test_denovo_ping

for dir in $all_results_dir/*; do
  python2 scripts/CallPing.py --input $dir --SNP  
done
