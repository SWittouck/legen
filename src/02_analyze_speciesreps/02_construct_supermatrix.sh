#!/usr/bin/env bash

# This script constructs a supermatrix of GTDB representative genomes of 
# species using 100 single-copy core genes. 

# dependencies: SCARAP v0.4.0, trimAl 1.4.rev15

fin_faapaths=../../results/representatives/faapaths.txt
fin_coregenome=../../results/representatives/core100/genes.tsv
dout=../../results/representatives/supermatrix

threads=16

# construct supermatrix on 838 representatives with 100 core genes 
scarap concat $fin_faapaths $fin_coregenome $dout -t $threads

# trim supermatrix: remove columns where > 10% of the sequences has a gap
trimal \
  -in $dout/supermatrix_aas.fasta \
  -out $dout/supermatrix_aas_trimmed.fasta \
  -gt 0.90 \
  -keepheader
