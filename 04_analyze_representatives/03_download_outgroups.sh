#!/usr/bin/env bash

# dependency: proclasp version 1.0
# remark: make sure that the proclasp script "download_fnas.sh" is in your path

fin_outgroups=../data_v3/outgroups/outgroup_genomes.tsv
dout=../data_v3/outgroups/genomes

[ -d $dout ] || mkdir -p $dout

download_fnas.sh $fin_outgroups $dout
