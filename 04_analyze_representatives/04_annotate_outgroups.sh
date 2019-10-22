#!/usr/bin/env bash

# dependency: prodigal version 2.6.3

threads=16

din_fnas=../data_v3/outgroups/genomes
dout_prodigal=../data_v3/outgroups/genes

# make output dirs if they don't exist
for dout in $dout_prodigal/{gffs,ffns,faas,logs} ; do
  [ -d $dout ] || mkdir -p $dout
done

# function to predict genes for one genome
predict_genes() {

  fin_genome=$1
  dout_prodigal=$2
  
  # extract genome name from path
  re="(GC[AF]_[0-9]+\.[0-9])"
  [[ $fin_genome =~ $re ]] && genome=${BASH_REMATCH[1]}

  # unzip genome
  gunzip $fin_genome

  # run prodigal
  prodigal \
    -f gff \
    -i ${fin_genome%.gz} \
    -o $dout_prodigal/gffs/${genome}.gff \
    -d $dout_prodigal/ffns/${genome}.ffn \
    -a $dout_prodigal/faas/${genome}.faa \
    2> $dout_prodigal/logs/${genome}.txt

  # rezip genome
  gzip ${fin_genome%.gz}

}

export -f predict_genes

# predict genes in parallel
parallel \
  --jobs $threads \
  --no-notice \
  --verbose \
  predict_genes {.} $dout_prodigal \
  ::: $din_fnas/*.fna.gz

# zip genes in parallel
parallel \
  --jobs $threads \
  --no-notice \
  --verbose \
  gzip {} \
  ::: $dout_prodigal/{gffs,ffns,faas}/*
