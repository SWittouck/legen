#!/usr/bin/env bash

# This script infers the pangenome of all dereplicated genomes using a 
# hierarchical strategy. 

# dependencies: SCARAP

din_faas=../../results/all/genes/faas/
fin_accessions=../../results/dereps/accessions.txt
fin_species=../../results/dereps/genomes_species.tsv
dout=../../results/dereps/

threads=16

# infer pangenome in a hierarchical way
sed "s|^|$din_faas|; s|\$|.faa.gz|" $fin_accessions > $dout/faapaths.txt
scarap pan $dout/faapaths.txt $dout/pangenome -s $fin_species -t $threads
rm $dout/faapaths.txt
