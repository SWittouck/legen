#!/usr/bin/env bash

# dependencies: progenomics version 0.1.0, OrthoFinder version 2.1.2, 
# blast version 2.6.0, MCL version 14-137, HMMER version 3.1b2, 
# ROCR version 1.0.7

threads=16

din_faas=../data_v3/genes/faas
dout_scgs=../data_v3/scgs
dout_qc=../data_v3/quality_control

[[ -d $dout_scgs ]] || mkdir -p $dout_scgs
[[ -d $dout_qc ]] || mkdir -p $dout_qc

# save paths of .faa files (aa sequences of genomes) in a list
ls $din_faas/*.faa.gz > $dout_scgs/genomepaths.txt

# identify orthogroups that might be SCGs based on seed genomes
progenomics prepare_candidate_scgs \
 --fin_genomepaths $dout_scgs/genomepaths.txt \
 --n_seed_genomes 30 \
 --min_presence_in_seeds 25 \
 --dout $dout_scgs \
 --threads $threads \
 2>&1 | tee $dout_scgs/log_prepare_candidate_scgs.txt

# select SCGs from the candidates by requiring that they are
# present in a single copy in 95% of the genomes
progenomics select_scgs \
 --fin_score_table $dout_scgs/score_table.csv \
 --fin_candidate_scg_table $dout_scgs/candidate_scg_table.csv \
 --candidate_scg_cutoff 0.95 \
 --fout_scg_list $dout_scgs/scg_list.txt \
 --fout_genome_table $dout_qc/genome_table.csv \
 2>&1 | tee $dout_scgs/log_select_scgs.txt

zip $dout_scgs/score_table.csv.zip $dout_scgs/score_table.csv
rm $dout_scgs/score_table.csv
