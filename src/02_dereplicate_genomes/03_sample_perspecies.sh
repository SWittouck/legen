#!/usr/bin/env bash

# For each species that has two genomes or more, this script samples a maximum
# of 100 genomes, making sure that no two sampled genomes are more similar than
# 99.99% (cANI90). 

# dependencies: SCARAP v0.4.0

dio=../../results/all/perspecies_high_quality

threads=32

# loop over species
for dio_sp in $dio/* ; do

  echo $dio_sp
  
  # continue loop if sampling output already exists
  if [ -f $dio_sp/sample/seeds.txt ] ; then continue ; fi
  
  # perform sampling
  scarap sample $dio_sp/ffnpaths.txt $dio_sp/core100.tsv \
    $dio_sp/sample -i 0.9999 -m 100 --method mean90 -t $threads
    
  echo ""
  
done