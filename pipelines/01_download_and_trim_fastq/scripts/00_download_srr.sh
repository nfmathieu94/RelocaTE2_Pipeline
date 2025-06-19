#!/usr/bin/bash -l
#SBATCH -p epyc --mem 100gb --cpus-per-task=8 --out logs/00_download/srr_download.%a.log --time 24:00:00

module load sratoolkit

SAMPFILE=samp_files/download_ril_SRR.csv

# Get the line number corresponding to the SLURM task ID
N=${SLURM_ARRAY_TASK_ID}

IFS=,
# Extract the SRR and FILEBASE from the appropriate line in the file
tail -n +2 "$SAMPFILE" | sed -n "${N}p" | while read SRR FILEBASE; do

    # Download the fastq files and rename them
    fastq-dump --split-files --origfmt --gzip $SRR 

    # Rename the downloaded files
    if [[ -f ${SRR}_1.fastq.gz ]]; then
        mv ${SRR}_1.fastq.gz ${FILEBASE}_R1.fastq.gz
    fi

    if [[ -f ${SRR}_2.fastq.gz ]]; then
        mv ${SRR}_2.fastq.gz ${FILEBASE}_R2.fastq.gz
    fi

done
