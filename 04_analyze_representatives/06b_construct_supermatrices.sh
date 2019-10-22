#!/usr/bin/env bash

# dependency: progenomics >= v0.1.1, mafft >= v7.407

din=../data_v3/representatives_v3_3/candidate_scgs
din_faas_outgroups=../data_v3/outgroups/genes/faas
din_faas_lactos=../data_v3/genes/faas
din_ffns_outgroups=../data_v3/outgroups/genes/ffns
din_ffns_lactos=../data_v3/genes/ffns
fin_representatives=../data_v3/representatives_v3_3/representatives.txt
dout=../data_v3/representatives_v3_3/supermatrix

[ -d $dout ] || mkdir -p $dout
[ -d $dout/faas ] || mkdir -p $dout/faas
[ -d $dout/ffns ] || mkdir -p $dout/ffns

# select SCGs from candidates
progenomics select_scgs \
  --fin_score_table $din/score_table.csv \
  --fin_candidate_scg_table $din/candidate_scg_table.csv \
  --candidate_scg_cutoff 0.99 \
  --fout_scg_list $dout/scg_list.txt \
  --fout_genome_table $dout/genome_table.csv

# select genomes (all of them)
cut -f 1 -d , $dout/genome_table.csv | tail -n +2 > $dout/selected_genomes.txt

# construct an SCG matrix
progenomics construct_scg_matrix \
  --fin_score_table $din/score_table.csv \
  --fin_candidate_scg_table $din/candidate_scg_table.csv \
  --fin_genome_list $dout/selected_genomes.txt \
  --fin_scg_list $dout/scg_list.txt \
  --fout_scg_matrix $dout/scg_matrix.csv

# copy faas and ffns to output directory
cp $din_faas_outgroups/*.faa.gz $dout/faas
cp $din_ffns_outgroups/*.ffn.gz $dout/ffns
for genome in $(less $fin_representatives) ; do 
  cp $din_faas_lactos/$genome*.faa.gz $dout/faas
  cp $din_ffns_lactos/$genome*.ffn.gz $dout/ffns
done

# unzip faas and ffns
gunzip $dout/faas/*.faa.gz
gunzip $dout/fnns/*.ffn.gz

# construct nucleotide supermatrix
progenomics nucleotide_supermatrix_from_scg_matrix \
  --fin_scg_matrix $dout/scg_matrix.csv \
  --din_ffns $dout/faas \
  --din_faas $dout/ffns \
  --dout $dout

# remove copied faas and ffns
rm -r $dout/faas
rm -r $dout/ffns
