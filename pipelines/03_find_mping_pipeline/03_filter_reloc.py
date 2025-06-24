#!/usr/bin/env python3

import pandas as pd

# Input files
concat_reloc_path = "results/reloc_ril_results_processed/pop1_reloc_mping_results_raw.tsv"
path_to_outfile = "results/reloc_ril_results_processed/pop1_reloc_mping_results_filtered.tsv"
parental_mping_file = "inputs/parental_mpings/parental_mping_insertions.tsv"


# Filtering thresholds
passed_junction_read_num = 1
# passed_tsd = {"TTA", "TAA"}

# Load parental locations into a set of tuples (chr, start, end)
parental_mping_df = pd.read_csv(parental_mping_file, sep='\t', header=None, names=["chr", "start", "end", "parent"])
parental_locs = set(zip(parental_mping_df["chr"], parental_mping_df["start"], parental_mping_df["end"]))

# Open and filter
with open(concat_reloc_path, 'r') as infile, open(path_to_outfile, 'w') as outfile:
    for line in infile:
        line_split = line.strip().split('\t')
        if len(line_split) < 7:
            continue  # Skip malformed lines

        chrom, start, end = line_split[0], int(line_split[1]), int(line_split[2])
        meta_info = line_split[6]

        # Create buffer windows around parental locations
        # Accept if close to any parental location
        is_near_parental = False
        for p_chrom, p_start, p_end in parental_locs:
            if chrom == p_chrom and abs(start - p_start) <= 100 and abs(end - p_end) <= 100:
                is_near_parental = True
                break

        if is_near_parental:
            outfile.write(line)
            continue

        # Always keep if it's a parental location
        # if (chrom, start, end) in parental_locs:
        #     outfile.write(line)
        #     continue

        # Parse metadata
        meta_dict = {}
        for item in meta_info.split(";"):
            if "=" in item:
                key, value = item.split("=", 1)
                meta_dict[key] = value

        # Extract required fields
        tsd = meta_dict.get("TSD", "")
        left_reads = int(meta_dict.get("Left_junction_reads", 0))
        right_reads = int(meta_dict.get("Right_junction_reads", 0))

        # Apply filters
        if (
            left_reads > passed_junction_read_num
            and right_reads > passed_junction_read_num
            and len(tsd) == 3 and tsd != "singleton" and tsd != "insufficient_data"
        ):
            outfile.write(line)
