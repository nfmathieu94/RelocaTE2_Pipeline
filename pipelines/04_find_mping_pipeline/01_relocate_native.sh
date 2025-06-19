#!/usr/bin/bash -l
#SBATCH -p batch -N 1 -c 64 -n 1 --mem 50gb --out logs/test_with_repeatmasker/relocate2_native_with_repeatmasker.%a.log --time 48:00:00

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


SAMPLES=samp_files/trimmed_pop1_samples.csv
repeat=$(realpath lib/mping.fa)
genome=$(realpath genome/MSU_r7.fa)
origin=$(realpath fq_input/trimmed)
outdir=$(realpath relocate2_results_raw_5.11.25_characterizer_test)
existing_te=$(realpath repeatmasker/test_5.11.25/MSU_r7.fa.out)
# aln_in=$(realpath aln)
aligner=blat
size=500

start=$(date +%s)

# Read the specific line from the CSV file
tail -n +2 $SAMPLES | sed -n ${N}p | while IFS=, read STRAIN FILEBASE BATCH; do
  echo "Processing strain: $STRAIN"
  mkdir -p $outdir/$STRAIN
  mkdir -p $SCRATCH/$STRAIN
  
  echo "Looking for files matching $FILEBASE"
  find $origin -maxdepth 1 \( -name "${FILEBASE/R[12]/R1}" -o -name "${FILEBASE/R[12]/R2}" \) | while read a; do
    echo "Linking $a to $SCRATCH/$STRAIN"
    ln -s "$a" "$SCRATCH/$STRAIN/$(basename "$a")"
  done

  echo "Contents of $SCRATCH/$STRAIN:"
  ls -lh $SCRATCH/$STRAIN
  
  relocaTE2.py --te_fasta $repeat --reference_ins $existing_te --genome_fasta $genome --fq_dir $SCRATCH/$STRAIN --mate_1_id _R1 --mate_2_id _R2 \
    --bam aln/$STRAIN   --outdir $outdir/$STRAIN --sample $STRAIN --split --run \
    --size $size --step 1234567 --mismatch 2 --cpu $CPU --aligner $aligner --verbose 3



# Uncomment the following line if you want to clean up temp directories after processing
  # rm -rf $SCRATCH/$STRAIN
done

end=$(date +%s)
runtime=$((end-start))

echo "Start: $start"
echo "End: $end"
echo "Run time: $runtime"

echo "Done"
