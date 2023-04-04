#!/usr/bin/env bash

# This scripts infers a ML tree on the trimmed supermatrix. 

# dependency: IQ-TREE v1.6.12

din=../../results/representatives/supermatrix
dout=../../results/representatives/tree

threads=16

[ -d $dout ] || mkdir -p $dout

# remark: Ziheng Yang advises against I+G models in section 4.3.1.4 of his book
iqtree \
  -s $din/supermatrix_aas_trimmed.fasta \
  -pre $dout/lab \
  -m LG+F+G4 \
  -alrt 1000 -bb 1000 \
  -nt $threads \
  -mem 60G
