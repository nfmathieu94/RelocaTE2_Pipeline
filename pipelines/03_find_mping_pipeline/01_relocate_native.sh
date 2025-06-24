#!/usr/bin/bash -l
#SBATCH -p batch -N 1 -c 64 -n 1 --mem 50gb --out logs/relocate2_mping/relocate2_results_mping.%a.log --time 48:00:00

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


SAMPLES=inputs/sample_file/trimmed_pop1_samples.csv
REPEAT=$(realpath inputs/lib/mping.fa)
GENOME=$(realpath inputs/genome/MSU_r6.fa)
ORIGIN=$(realpath inputs/fq_input/trimmed)
OUTDIR=$(realpath results/relocate2_results_mping_raw)
EXISTING_TE=$(realpath inputs/repeatmasker/MSU_r7.fa.out)
ALN_IN=$(realpath inputs/alignments)
ALIGNER=blat
SIZE=200 # Insert size from 2020 PNAS paper

START=$(date +%s)

# Read the specific line from the CSV file
tail -n +2 $SAMPLES | sed -n ${N}p | while IFS=, read STRAIN FILEBASE BATCH; do
  echo "Processing strain: $STRAIN"
  mkdir -p $OUTDIR/$STRAIN
  mkdir -p $SCRATCH/$STRAIN
  
  echo "Looking for files matching $FILEBASE"
  find $ORIGIN -maxdepth 1 \( -name "${FILEBASE/R[12]/R1}" -o -name "${FILEBASE/R[12]/R2}" \) | while read a; do
    echo "Linking $a to $SCRATCH/$STRAIN"
    ln -s "$a" "$SCRATCH/$STRAIN/$(basename "$a")"
  done

  echo "Contents of $SCRATCH/$STRAIN:"
  ls -lh $SCRATCH/$STRAIN
  
  relocaTE2.py --te_fasta $REPEAT --reference_ins $EXISTING_TE --genome_fasta $GENOME --fq_dir $SCRATCH/$STRAIN --mate_1_id _R1 --mate_2_id _R2 \
    --bam $ALN_IN/$STRAIN   --outdir $OUTDIR/$STRAIN --sample $STRAIN --split --run \
    --size $SIZE --step 1234567 --mismatch 2 --cpu $CPU --aligner $ALIGNER --verbose 3



# Uncomment the following line if you want to clean up temp directories after processing
  # rm -rf $SCRATCH/$STRAIN
done

END=$(date +%s)
RUNTIME=$((END-START))

echo "Start: $START"
echo "End: $END"
echo "Run time: $RUNTIME"

echo "Done"
