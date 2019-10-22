#!/usr/bin/env bash

# dependencies: OrthoFinder v2.3.3, MMseqs2 version d36de

din_faas_outgroups=../data_v3/outgroups/genes/faas
din_faas_lactos=../data_v3/genes/faas
fin_representatives=../data_v3/representatives_v3_3/representatives.txt
dout=../data_v3/representatives_v3_3/pangenome

threads=16

[[ -d $dout ]] || mkdir -p $dout

# copy faas to OrthoFinder directory
cp $din_faas_outgroups/*.faa.gz $dout
for genome in $(less $fin_representatives) ; do 
  cp $din_faas_lactos/$genome*.faa.gz $dout
done

# unzip faas
gunzip $dout/*.faa.gz

# run OrthoFinder
orthofinder -og -S mmseqs -t $threads -f $dout \
  2>&1 | tee $dout/log_infer_pangenome.txt

# remove copied faass
rm $dout/*.faa

# remove extra layer of results dirs
mv $dout/OrthoFinder/Results_*/* $dout/OrthoFinder/
rm -r $dout/OrthoFinder/Results_*

# remove extremely large workdir created by OrthoFinder
rm -r data/pangenome/OrthoFinder/WorkingDirectory/
