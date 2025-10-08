#!/usr/bin/env bash

# This script infers the pangenome of representative genomes for species
# of Lactobacillales. 

# dependencies: SCARAP

din_faas=../../results/all/genes/faas/
fin_accessions=../../results/speciesreps/accessions.txt
dout=../../results/speciesreps/

threads=16

# infer the pangenome of the representative genomes 
sed "s|^|$din_faas|; s|\$|.faa.gz|" $fin_accessions > $dout/faapaths.txt
scarap pan $dout/faapaths.txt $dout/pangenome -t $threads
rm $dout/faapaths.txt
