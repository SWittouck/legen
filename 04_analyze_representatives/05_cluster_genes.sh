#!/usr/bin/env bash

fin_scg_matrix_subset=../data_v3/representatives_v3_2/scg_matrix.csv
din_faas=../data_v3/genes/faas
dout=../data_v3/representatives_v3_2/pangenome

threads=16

[[ -d $dout ]] || mkdir -p $dout

# extract list of genome names from scg matrix
genomes=$(cat $fin_scg_matrix_subset | cut -d , -f 1 | tail -n +2) 

# copy genomes to OrthoFinder directory
for genome in $genomes ; do
  fin_faa=$(ls $din_faas/$genome*)
  cp $fin_faa $dout
done

# unzip
gunzip $dout/*.faa.gz

orthofinder -M msa -os -t $threads -f $dout \
  2>&1 | tee $dout/log_cluster_genes.txt

# rezip
gzip $dout/*.faa
