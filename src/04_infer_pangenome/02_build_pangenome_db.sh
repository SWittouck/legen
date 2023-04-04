#!/usr/bin/env bash

# This script builds a pangenome profile database for the Lactobacillales
# by first collecting the pseudogenomes from the hierarchical pangenome
# inference process (set of representative genes of species-level orthogroups)
# and then building a profile database using these sequences. The idea is that
# these sequences are a dereplicated version of the full pangenome. Only 
# orthogroups present in at least two species will be represented in the 
# database. 

# dependencies: SCARAP version e5d00e6

din_faas=../../results/all/genes/faas
fin_pseudogenomes=../../results/dereplicated/pangenome/pseudogenomes.tsv
fin_pseudopangenome=../../results/dereplicated/pangenome/pseudopangenome.tsv
dio_pseudogenomes=../../results/dereplicated/pseudogenomes
dout_db=../../results/dereplicated/pangenome-db

threads=16

# collect amino acid sesquences of pseudogenomes
scarap fetch $din_faas $fin_pseudogenomes $dio_pseudogenomes

# build profile db for orthogroups occurring in at least two species
scarap build $dio_pseudogenomes/fastas $fin_pseudopangenome $dout_db \
  -p 0.002 -t $threads
