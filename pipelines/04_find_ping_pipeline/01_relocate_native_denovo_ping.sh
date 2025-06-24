#!/usr/bin/bash -l
#SBATCH -p epyc -N 1 -c 64 -n 1 --mem 40gb --out logs/relocate2_find_ping/relocate2_find_ping.%a.log --time 48:00:00

module load relocate2

# Use SLURM's allocated CPUs if available
CPU=2
if [ $SLURM_CPUS_ON_NODE ]; then
  CPU=$SLURM_CPUS_ON_NODE
fi

# Get the task ID from SLURM array or from command line argument
N=${SLURM_ARRAY_TASK_ID}
if [ -z $N ]; then
  N=$1
fi

if [ -z $N ]; then
  echo "Cannot run without a task number provided either via --array in sbatch or command line argument"
  exit 1
fi

SAMPLES=inputs/sample_files/trimmed_pop1_samples.csv
REPEAT=$(realpath inputs/lib/ping.fa)
GENOME=$(realpath inputs/genome/MSU_r7.fa)
ORIGIN=$(realpath inputs/fq_input/trimmed)
OUDIR=$(realpath results/relocate2_results_find_ping_raw)
EXISTING_TE=$(realpath inputs/repeatmasker/MSU_r7.fa.out)

ALIGNER=blat
SIZE=200 # Number from 2020 PNAS paper

START=$(date +%s)

# Read the specific line from the CSV file
tail -n +2 $SAMPLES | sed -n ${N}p | while IFS=, read STRAIN FILEBASE BATCH; do
  echo "Processing strain: $STRAIN"
  mkdir -p $OUDIR/$STRAIN
  mkdir -p $SCRATCH/$STRAIN
  
  echo "Looking for files matching $FILEBASE"
  find $ORIGIN -maxdepth 1 \( -name "${FILEBASE/R[12]/R1}" -o -name "${FILEBASE/R[12]/R2}" \) | while read a; do
    echo "Linking $a to $SCRATCH/$STRAIN"
    ln -s "$a" "$SCRATCH/$STRAIN/$(basename "$a")"
  done

  echo "Contents of $SCRATCH/$STRAIN:"
  ls -lh $SCRATCH/$STRAIN
  
  relocaTE2.py --te_fasta $REPEAT --genome_fasta $GENOME --reference_ins $EXISTING_TE --fq_dir $SCRATCH/$STRAIN --mate_1_id _R1 --mate_2_id _R2 \
    --outdir $OUTDIR/$STRAIN --sample $STRAIN --split --run \
    --size $SIZE --step 1234567 --mismatch 0 --mismatch_junction 0 --cpu $CPU --aligner $ALIGNER --verbose 4

# Uncomment the following line if you want to clean up temp directories after processing
  # rm -rf $SCRATCH/$STRAIN
done

END=$(date +%s)
RUNTIME=$((END-START))

echo "Start: $START"
echo "End: $END"
echo "Run time: $RUNTIME"

echo "Done"
