#!/bin/bash -l
#SBATCH -p epyc --mem 91gb --cpus-per-task=8 --out logs/alignment_logs/bwa.%a.log --time 16:00:00

echo "Script started on $(date)"

CPU=8
if [ "$SLURM_CPUS_ON_NODE" ]; then
  CPU=$SLURM_CPUS_ON_NODE
fi

N=${SLURM_ARRAY_TASK_ID}
if [ -z "$N" ]; then
  N=$1
fi

if [ -z "$N" ]; then
  echo "Cannot run without a number provided either cmdline or --array in sbatch"
  exit 1
fi

GENOME=inputs/genome/MSU_r7.fa
FASTQFOLDER=inputs/fq_input
SAMPFILE=inputs/sample_file/trimmed_pop1_samples.csv
OUTDIR=inputs/alignments

mkdir -p $OUTDIR

module load bwa
module load samtools

if [ ! -f $GENOME.sa ]; then
   bwa index $GENOME || { echo "Failed to index genome"; exit 1; }
fi

IFS=,
tail -n +2 "$SAMPFILE" | sed -n "${N}p" | while read LINE FILEBASE READGROUP; do
  LEFT=$(ls $FASTQFOLDER/$FILEBASE | sed -n 1p)
  RIGHT=$(ls $FASTQFOLDER/$FILEBASE | sed -n 2p)

  if [[ -z "$LEFT" || -z "$RIGHT" ]]; then
    echo "Missing files for $FILEBASE"
    exit 1
  fi

  echo "$LEFT $RIGHT for $FASTQFOLDER/$FILEBASE"

  SAMPLE_OUTDIR=$OUTDIR/$LINE
  mkdir -p $SAMPLE_OUTDIR

  # Alignment
  if ! bwa mem -t "$CPU" -R "@RG\tID:${READGROUP}\tSM:${LINE}" $GENOME $LEFT $RIGHT | \
     samtools view -b -o "$SAMPLE_OUTDIR/${LINE}.bam" -; then
    echo "Alignment failed for $LINE"; exit 1;
  fi

  # Name sorting
  if ! samtools sort -n -@ "$CPU" -o "$SAMPLE_OUTDIR/${LINE}.name_sorted.bam" "$SAMPLE_OUTDIR/${LINE}.bam"; then
    echo "Name sorting failed for $LINE"; exit 1;
  fi

  # Adding mate score tags
  if ! samtools fixmate -m "$SAMPLE_OUTDIR/${LINE}.name_sorted.bam" "$SAMPLE_OUTDIR/${LINE}.fixmate.bam"; then
    echo "Fixmate failed for $LINE"; exit 1;
  fi

  # Coordinate sorting and marking duplicates
  if ! samtools sort -@ "$CPU" -o "$SAMPLE_OUTDIR/${LINE}.sorted.bam" "$SAMPLE_OUTDIR/${LINE}.fixmate.bam"; then
    echo "Coordinate sorting failed for $LINE"; exit 1;
  fi

  if ! samtools markdup -@ "$CPU" "$SAMPLE_OUTDIR/${LINE}.sorted.bam" "$SAMPLE_OUTDIR/${LINE}.sorted.markdup.bam"; then
    echo "Markduplicates failed for $LINE"; exit 1;
  fi

  # Index marked duplicates BAM file
  if ! samtools index "$SAMPLE_OUTDIR/${LINE}.sorted.markdup.bam" -@ "$CPU"; then
    echo "Indexing marked duplicates BAM failed for $LINE"; exit 1;
  fi

  # Generate flagstat report
  if ! samtools flagstat "$SAMPLE_OUTDIR/${LINE}.sorted.markdup.bam" > "$SAMPLE_OUTDIR/${LINE}.sorted.markdup.flagstat.txt"; then
    echo "Generating flagstat report failed for $LINE"; exit 1;
  fi
  

  # Remove intermediate files
  rm "$SAMPLE_OUTDIR/${LINE}.bam"
  rm "$SAMPLE_OUTDIR/${LINE}.name_sorted.bam"
  rm "$SAMPLE_OUTDIR/${LINE}.fixmate.bam"
  rm "$SAMPLE_OUTDIR/${LINE}.sorted.bam"
done
