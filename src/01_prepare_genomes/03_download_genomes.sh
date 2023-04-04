#!/usr/bin/env bash

# This script downloads an assembly (.fna file) from the NCBI database for all 
# genomes. 

# dependencies: ProClasp v1.0

fin=../../results/all/genomes_accessions.txt
dout=../../data/genomes_lactobacillales_gtdb-r207
fout_log=../../results/all/download_fnas.log

if ! [ -d $dout ] ; then

  download_fnas.sh $fin $dout 2>&1 | tee $fout_log

fi