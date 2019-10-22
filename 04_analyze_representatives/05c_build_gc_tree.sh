#!/usr/bin/env bash

# dependency: iqtree version 1.6.11

din=../data_v3/representatives_v3_3/pangenome
dout=../data_v3/representatives_v3_3/tree_gc

[ -d $dout ] || mkdir -p $dout

iqtree \
  -s $din/gene_content.fasta \
  -pre $dout/lacto_gc \
  -m GTR2+G+ASC \
  -alrt 1000 -bb 1000 \
  -nt 16
