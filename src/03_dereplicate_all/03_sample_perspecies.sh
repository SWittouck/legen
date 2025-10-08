#!/usr/bin/env bash

# For every species, this script samples a maximum of 100 genomes, making sure 
# that no two sampled genomes are more similar than 99.99% (cANI90). 

# dependencies: SCARAP

din_ffns=../../results/all/genes/ffns/
din_core=../../results/all/core100_perspecies/
fin_genomes=../../results/all/genomes.csv
dout_derep=../../results/all/dereplication/
dout_dereps=../../results/dereps/

threads=16

# create output folders
[ -d $dout_derep ] || mkdir $dout_derep
[ -d $dout_dereps ] || mkdir $dout_dereps

# loop over species
for fin_core in $din_core/*.tsv ; do

  species=$(basename $fin_core .tsv)

  echo $species

  # continue loop if sampling output already exists
  if [ -f $dout_derep/$species/seeds.txt ] ; then continue ; fi

  # perform sampling
  scarap sample $din_ffns $fin_core $dout_derep/$species \
    -i 0.9999 -m 100 --method mean90 -t $threads

  echo ""

done

# concatenate all the selected genomes
cat $dout_derep/*/seeds.txt > $dout_dereps/accessions.txt

# subset genome metadata to dereps
awk -F ',' 'NR == FNR {a[$1]; next} FNR == 1 || $1 in a' \
  $dout_dereps/accessions.txt $fin_genomes > $dout_dereps/genomes.csv

# create genome table with only the species
tail -n +2 $dout_dereps/genomes.csv |\
  cut -d ',' -f 1,12 |\
  tr ',' '\t' >\
  $dout_dereps/genomes_species.tsv
