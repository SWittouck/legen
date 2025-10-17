#!/usr/bin/env bash

# This script runs eggnogmapper on representative sequences of all orthogroups.

# dependencies: eggnogmapper

din_db=../../data/eggnog/
fin_seqs=../../results/speciesreps/annotation/sequences.fasta.gz
dout=../../results/speciesreps/annotation/annotation/

# create output folder
[ -d $dout ] || mkdir $dout

# decompress stuff
gunzip $fin_seqs ; fin_seqs=${fin_seqs%.gz}

# run eggnogmapper
emapper.py --data_dir $din_db -i $fin_seqs -o $dout/lacto \
  --tax_scope Firmicutes --cpu 0

# compress stuff
for fout in $dout/* ; do mv $fout $fout.tsv ; done
gzip $dout/*
gzip $fin_seqs
