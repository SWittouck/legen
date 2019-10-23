#!/usr/bin/env bash

fin_rrnas_16S=../data_v3/taxonomy/lgc_16S_genes.fasta
fout_rrnas_16S=../data_v3/taxonomy/lgc_16S_genes.txt

# extract the genome name from all 16S sequences found
# so that we can count the number of sequences found per 
# genome
grep ">" $fin_rrnas_16S | cut -f 2 -d '>' | cut -f 1 -d ':' \
  > $fout_rrnas_16S
