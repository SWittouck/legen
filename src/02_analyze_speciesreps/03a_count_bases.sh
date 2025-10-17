#!/usr/bin/env bash

# This script calculates base frequencies in representative genomes of
# Lactobacillaceae species. 

# dependencies: python, biopython, pandas

din_ffns=../../results/all/genes/ffns/
fin_acc=../../results/speciesreps/accessions.txt
dout=../../results/speciesreps/gc_content

# create output folder
[ -d $dout ] || mkdir $dout

# count bases
../tools/count_bases.py $din_ffns $fin_acc > $dout/basecounts.csv

# compress counts 
gzip $dout/basecounts.csv
