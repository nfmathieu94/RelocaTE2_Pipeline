#!/usr/bin/python3

import os


def create_sampfile(input_head_dir, out_path):
    # Ensure the input directory exists
    if not os.path.isdir(input_head_dir):
        print(f"Error: The directory {input_head_dir} does not exist.")
        return 1

    # Open the output file for writing
    with open(out_path, 'w') as out_file:
        # Write the header of the output file
        out_file_header = 'Line,File\n'
        out_file.write(out_file_header)
        
        # Regular expression replacement for read group
        read_group_expr = 'R[12]'

        # Iterate over each file in the input directory
        for file in os.listdir(input_head_dir):
            # Ensure the file is a fastq file
            if not file.endswith(".fastq.gz"):
                continue

            # Split the file name into components
            file_split = file.split('_')

            # Check if the filename structure is as expected
            if len(file_split) < 3:
                print(f"Skipping file {file}: Unexpected filename format.")
                continue

            # Extract the relevant components from the filename
            line = file_split[0]
            trim_status = file_split[1]
            extension_split = file_split[2].split('.', )
            read_group = extension_split[0]
            extension_1 = extension_split[1]
            extension_2 = extension_split[2]


            # Only use read group R1 to avoid duplication
            if 'R1' in read_group:
                # Create the new file line for the CSV
                new_file_line = f'{line},{line}_{trim_status}_{read_group_expr}.{extension_1}.{extension_2},Pop1\n'

                # Write the new line to the output file
                out_file.write(new_file_line)
    
    print(f"Output written to {out_path}")
    return 0


# Define the input directory and output file path
fastq_file_dir = "inputs/fq_input/trim"
out_file_path = "sample_files/trimmed_pop1_samples.csv"

# Call the function to create the sample file
create_sampfile(fastq_file_dir, out_file_path)
