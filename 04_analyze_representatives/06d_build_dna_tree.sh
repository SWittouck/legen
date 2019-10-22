#!/usr/bin/env bash

# dependency: iqtree version 1.6.11

din=../data_v3/representatives_v3_3/supermatrix
dout=../data_v3/representatives_v3_3/tree_dna

[ -d $dout ] || mkdir -p $dout

iqtree \
  -s $din/supermatrix_nucs_trimmed.fasta \
  -pre $dout/lacto_dna \
  -m GTR+G \
  -alrt 1000 -bb 1000 \
  -nt 16
