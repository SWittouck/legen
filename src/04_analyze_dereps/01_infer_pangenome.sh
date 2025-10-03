#!/usr/bin/env bash

# This script infers the pangenome of all dereplicated genomes using a 
# hierarchical strategy. 

# dependencies: SCARAP v0.4.0

fin_faapaths=../../results/dereplicated/faapaths.txt
fin_species=../../results/dereplicated/genomes_species.tsv
dout=../../results/dereplicated/pangenome

threads=16

# infer pangenome in a hierarchical way
scarap pan $fin_faapaths $dout -s $fin_species -t $threads -c
