#!/usr/bin/env bash

# This scripts infers a ML tree on the trimmed supermatrix of species 
# representative genomes. 

# dependency: IQ-TREE

din=../../results/speciesreps/supermatrix
dout=../../results/speciesreps/tree

threads=16

[ -d $dout ] || mkdir -p $dout

# decompress supermatrices
gunzip $din/supermatrix_aas_trimmed.fasta.gz

# infer maximum likelihood tree
# remark: Ziheng Yang advises against I+G models in section 4.3.1.4 of his book
iqtree \
  -s $din/supermatrix_aas_trimmed.fasta \
  --prefix $dout/concat \
  -m LG+F+G4 \
  -B 1000 \
  -T AUTO \
  -mem 60G
  
# compress supermatrix
gzip $din/supermatrix_aas_trimmed.fasta
