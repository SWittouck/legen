#!/bin/bash

# This script predicts and translates genes for all assemblies. 

# dependency: Prodigal v2.6.3

din_fnas=../../data/genomes_lactobacillales_gtdb-r207
dout_prodigal=../../results/all/genes
dout_paths=../../results/all

threads=32

# make output dirs if they don't exist
for dout in $dout_prodigal/{gffs,ffns,faas,logs} ; do
  [ -d $dout ] || mkdir -p $dout
done

# function to predict genes for one genome
predict_genes() {

  fin_genome=$1
  dout_prodigal=$2
  
  # extract genome name from path
  re="((GC[AF]_[0-9]+\.[0-9])|(AMB-R[0-9]{3}))"
  [[ $fin_genome =~ $re ]] && genome=${BASH_REMATCH[1]}
  
  # exit function if faa already exists
  [[ ! -f $dout_prodigal/faas/${genome}.faa.gz ]] || return 0

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
  
  # zip gff, ffn, faa and txt
  gzip $dout_prodigal/gffs/${genome}.gff
  gzip $dout_prodigal/ffns/${genome}.ffn
  gzip $dout_prodigal/faas/${genome}.faa
  gzip $dout_prodigal/logs/${genome}.txt

}

export -f predict_genes

# predict genes
ls $din_fnas | grep \.fna\.gz | parallel \
  --jobs $threads \
  --no-notice \
  --verbose \
  predict_genes $din_fnas/{} $dout_prodigal

# write faapaths and ffnpaths
ls $dout_prodigal/faas/*.faa.gz > $dout_paths/faapaths.txt
ls $dout_prodigal/ffns/*.ffn.gz > $dout_paths/ffnpaths.txt
