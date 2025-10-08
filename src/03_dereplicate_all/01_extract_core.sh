#!/usr/bin/env bash

# This script identifies the top 100 single-copy core genes in representative
# genomes of species of Lactobacillales and extracts them from all genomes. 

# dependencies: SCARAP

din_faas=../../results/all/genes/faas/
fin_acc_repr=../../results/speciesreps/accessions.txt
fin_acc_all=../../results/all/accessions.txt
fin_pan_repr=../../results/speciesreps/pangenome/pangenome.tsv

dout_repr=../../results/speciesreps
dout_all=../../results/all

threads=16

# build a profile database of the top 100 single-copy core genes
sed "s|^|$din_faas|; s|\$|.faa.gz|" $fin_acc_repr > $dout_repr/faapaths.txt
scarap build $dout_repr/faapaths.txt $fin_pan_repr $dout_repr/core100 \
  -p 0.9 -m 100 -t $threads
rm $dout_repr/faapaths.txt
  
# identify the top 100 core genes in all genomes 
sed "s|^|$din_faas|; s|\$|.faa.gz|" $fin_acc_all > $dout_all/faapaths.txt
scarap search $dout_all/faapaths.txt $dout_repr/core100 $dout_all/core100 \
  -t $threads
rm $dout_all/faapaths.txt
