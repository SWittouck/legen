#!/usr/bin/env bash

# dependency: EMBOSS version 6.6.0.0

fin_supermatrix=../data_v3/similarities/cnis/supermatrix_nucs.fasta
dout=../data_v3/similarities/cnis

[ -d $dout ] || mkdir -p $dout

# calculate the pairwise CNIs from the nucleotide supermatrix
distmat \
  -sequence $fin_supermatrix \
  -nucmethod 0 \
  -outfile $dout/cnis.distmat \
  2>&1 | tee $dout/../log_calculate_cnis.txt
