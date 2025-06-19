#!/usr/bin/bash -l
#SBATCH -p batch -c 16 --mem 30gb --out logs/01_fastp/fastp_just_adapters.%a.log

CPU=2
if [ $SLURM_CPUS_ON_NODE ]; then
  CPU=$SLURM_CPUS_ON_NODE
fi

N=${SLURM_ARRAY_TASK_ID}
if [ -z $N ]; then
  N=$1
fi

if [ -z $N ]; then
  echo "cannot run without a number provided either cmdline or --array in sbatch"
  exit
fi

module load fastp

SAMPFILE=samp_files/raw_pop1_samples.csv
INPUTDIR=raw_data
OUTDIR=trim_just_adapters

IFS=,
tail -n +2 $SAMPFILE | sed -n ${N}p | while read LINE FILEBASE
do
  mkdir -p $OUTDIR
  LEFT=$(ls $INPUTDIR/$FILEBASE | sed -n 1p)
  RIGHT=$(ls $INPUTDIR/$FILEBASE | sed -n 2p)

  fastp \
    --detect_adapter_for_pe \
    -w $CPU \
    --disable_quality_filtering \
    --disable_length_filtering \
    --dont_overwrite \
    --json "$OUTDIR/$LINE.json" \
    --html "$OUTDIR/$LINE.html" \
    -i "$LEFT" -I "$RIGHT" \
    -o "$OUTDIR/${LINE}_trim_R1.fastq.gz" -O "$OUTDIR/${LINE}_trim_R2.fastq.gz"
done
