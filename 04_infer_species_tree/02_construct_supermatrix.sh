#!/usr/bin/env bash

# dependencies: progenomics version 0.9

fin_scg_matrix=../data_v3/genome_clusters/scg_matrix_subset.csv
din_ffns=../data_v3/genes/ffns
din_faas=../data_v3/genes/faas
dout=../data_v3/genome_clusters/supermatrix

[[ -d $dout ]] || mkdir -p $dout

# construct a supermatrix (concatenated alignment of 
# core genes) of all genomes that passed qc
progenomics nucleotide_supermatrix_from_scg_matrix \
 --fin_scg_matrix $fin_scg_matrix \
 --din_ffns $din_ffns \
 --din_faas $din_faas \
 --dout $dout \
 2>&1 | tee $dout/log_construct_supermatrix.txt
