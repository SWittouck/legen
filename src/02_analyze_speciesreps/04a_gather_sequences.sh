#!/usr/bin/env bash

# This script samples up to ten representative amino acid sequences per 
# orthogroup for all orthogroups. 

# dependencies: SCARAP

din_faas=../../results/all/genes/faas
fin_pan=../../results/speciesreps/pangenome/pangenome.tsv
fin_genomes=../../results/speciesreps/genomes.csv
dout=../../results/speciesreps/annotation

# create output folder
[ -d $dout ] || mkdir $dout

# sample genes
../tools/sample_genes.py $fin_pan $fin_genomes $dout/sample.tsv 10

# gather sequences
scarap fetch $din_faas $dout/sample.tsv $dout/sequences

# put all sequences into one fasta file
find $dout/sequences/fastas/ -name '*.fasta' -exec cat {} \; \
  > $dout/sequences.fasta
rm -r $dout/sequences/fastas/ 

# compress large files
gzip $dout/sample.tsv
gzip $dout/sequences.fasta
