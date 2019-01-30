#!/usr/bin/env bash

# dependency: progenomics version 0.9

threads=16

fin_genome_table=../data_v3/quality_control/genome_table.csv
dout=../data_v3/quality_control

[[ -d $dout ]] || mkdir -p $dout

# select genomes by requiring that they have > 90% completeness and
# < 10% redundancy
progenomics select_genomes \
 --fin_genome_table $fin_genome_table \
 --completeness_cutoff 0.90 \
 --redundancy_cutoff 0.10 \
 --fout_genome_list $dout/genome_list.txt \
 2>&1 | tee $dout/log_select_genomes.txt
