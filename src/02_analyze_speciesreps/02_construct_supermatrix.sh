#!/usr/bin/env bash

# This script constructs a supermatrix of representative genomes for species
# of Lactobacillales using 100 single-copy core genes. 

# dependencies: SCARAP, trimAl

din_faas=../../results/all/genes/faas/
fin_accessions=../../results/speciesreps/accessions.txt
fin_pangenome=../../results/speciesreps/pangenome/pangenome.tsv
dout=../../results/speciesreps/

threads=16

# construct supermatrix
sed "s|^|$din_faas|; s|\$|.faa.gz|" $fin_accessions > $dout/faapaths.txt
scarap concat $dout/faapaths.txt $fin_pangenome $dout/supermatrix -m 100 \
  -t $threads
rm $dout/faapaths.txt

# trim supermatrix: remove columns where > 10% of the sequences has a gap
trimal \
  -in $dout/supermatrix/supermatrix_aas.fasta \
  -out $dout/supermatrix/supermatrix_aas_trimmed.fasta \
  -gt 0.90 \
  -keepheader

# compress supermatrices
gzip $dout/supermatrix/supermatrix_aas.fasta
gzip $dout/supermatrix/supermatrix_aas_trimmed.fasta
