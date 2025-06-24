#!/usr/bin/bash -l

INPUT=results/relocate2_results_find_ping_raw/*/repeat/results/ALL.all_nonref_insert.Ping.gff
OUTPUT=relocate2_results_find_mping_filtered/all_ping_results.tsv

cat $INPUT \
  > $OUTPUT 
