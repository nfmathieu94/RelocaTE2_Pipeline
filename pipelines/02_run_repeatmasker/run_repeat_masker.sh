#!/usr/bin/bash -l
#SBATCH -p epyc -N 1 -c 64 -n 1 --mem 50gb --out logs/repeat_masker/repeat_masker_mping_ping_pong.%a.log --time 24:00:00

TE_FASTA=inputs/lib/mPing_Ping_Pong.fa
GENOME=inputs/genome/MSU_r7.fa
OUT_DIR=inputs/repeatmasker

module load RepeatMasker

mkdir -p $OUT_DIR

RepeatMasker -pa 8 -lib $TE_FASTA -nolow -norna -no_is -dir $OUT_DIR $GENOME
