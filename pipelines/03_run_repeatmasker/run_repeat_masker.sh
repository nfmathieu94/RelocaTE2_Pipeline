#!/usr/bin/bash -l
#SBATCH -p epyc -N 1 -c 64 -n 1 --mem 50gb --out logs/repeat_masker/test_5_11_25.%a.log --time 24:00:00

TE_FASTA=lib/elements/mPing_Ping_Pong.fa
GENOME=genome/MSU_r7.fa
OUT_DIR=repeatmasker/test2_5.11.25

module load RepeatMasker

mkdir -p $OUT_DIR

RepeatMasker -pa 8 -lib $TE_FASTA -nolow -norna -no_is -dir $OUT_DIR $GENOME
