#!/usr/bin/env bash

# dependency: progenomics version 0.9

fin_score_table=../data_v3/scgs/score_table.csv
fin_candidate_scg_table=../data_v3/scgs/candidate_scg_table.csv
fin_genome_list=../data_v3/quality_control/genome_list.txt
fin_scg_list=../data_v3/scgs/scg_list.txt
dout=../data_v3/similarities/cnis

[[ -d $dout ]] || mkdir -p $dout

# construct a matrix where the rows are genomes, the columns
# are scgs and the cells contains gene names
progenomics construct_scg_matrix \
 --fin_score_table $fin_score_table \
 --fin_candidate_scg_table $fin_candidate_scg_table \
 --fin_genome_list $fin_genome_list \
 --fin_scg_list $fin_scg_list \
 --fout_scg_matrix $dout/scg_matrix.csv \
 2>&1 | tee $dout/log_construct_scg_matrix.txt
