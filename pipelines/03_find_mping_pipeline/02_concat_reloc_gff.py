#!/usr/bin/python3
import os
import re

# Directory to loop through
base_dir = 'results/relocate2_results_mping_raw'
output_file = 'results/reloc_ril_results_processed/pop1_reloc_mping_results_raw.tsv'
sub_path_to_file = "repeat/results/ALL.all_nonref_insert.gff"

with open(output_file, 'w') as newfile:
    print(newfile)

# Function to create a new file with Ping information
def make_file(path_to_infile, path_to_outfile, file_name):
    line_list = []

    # Read the input file
    with open(path_to_infile, 'r') as infile:
        for line in infile:
            line_split = re.split('\t', line.strip())
            chr_num = line_split[0]
            start = line_split[3]
            end = line_split[4]
            strand = line_split[6]
            details = line_split[8]


            # Get TE type
            meta_info_line = re.split(';', line_split[8].strip())
            te_name_parts = re.split('=', meta_info_line[1].strip())
            te_name = te_name_parts[1]

            line_list.append(f'{chr_num}\t{start}\t{end}\t{strand}\t{te_name}\t{file_name}\t{details}')
            #print(line_list)

    # Write to the output file
    with open(path_to_outfile, 'a') as outfile:  # Need to change this, won't create new  file
        for item in line_list:
            outfile.write(item + '\n')  # Write the extracted data

# Loop through each subdirectory in the base directory
for subdir in os.listdir(base_dir):
    subdir_path = os.path.join(base_dir, subdir)

    # Check if it is a directory
    if os.path.isdir(subdir_path):
        #print(subdir_path)
        # Define the path to the specific file you want to find
        file_path = os.path.join(subdir_path, sub_path_to_file)

        # Check if the file exists
        if os.path.exists(file_path):
            # Call the function to process the file and write to the output
            make_file(file_path, output_file, subdir)
