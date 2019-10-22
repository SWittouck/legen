#!/usr/bin/env bash

# dependency: progenomics version 0.1.0

threads=16

din_faas_outgroups=../data_v3/outgroups/genes/faas
din_faas_lactos=../data_v3/genes/faas
fin_representatives=../data_v3/representatives_v3_3/representatives.txt
dout=../data_v3/representatives_v3_3/candidate_scgs

[ -d $dout ] || mkdir -p $dout

# copy faas to output directory
cp $din_faas_outgroups/*.faa.gz $dout
for genome in $(less $fin_representatives) ; do 
  cp $din_faas_lactos/$genome*.faa.gz $dout
done

# unzip faas
gunzip $dout/*.faa.gz

# create list with paths to faas
ls $din_faas/*.faa > genomepaths.txt

# find candidate SCGs
progenomics prepare_candidate_scgs \
  --fin_genomepaths genomepaths.txt \
  --n_seed_genomes 30 \
  --min_presence_in_seeds 25 \
  --dout $dout \
  --threads $threads

# remove copied faas
rm $dout/*.faa

# remove list with paths to faas
rm genomepaths.txt
