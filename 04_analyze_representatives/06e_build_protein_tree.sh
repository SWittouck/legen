#!/usr/bin/env bash

# dependency: iqtree version 1.6.11

din=../data_v3/representatives_v3_3/supermatrix
dout=../data_v3/representatives_v3_3/tree_protein

[ -d $dout ] || mkdir -p $dout

iqtree \
  -s $din/supermatrix_aas_trimmed.fasta \
  -pre $dout/lacto_protein \
  -m LG+G+F \
  -alrt 1000 -bb 1000 \
  -nt 16
