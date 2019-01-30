#!/bin/bash

# Dependency: pyani version 0.2.7

dout=../data_v3/genomes

[ -d $dout ] || mkdir -p $dout

# download genomes of Lactobacillaceae and Leuconostocaceae
genbank_get_genomes_by_taxon.py \
  --outdir $dout \
  --taxon 33958,81850 \
  --verbose \
  --force \
  --noclobber \
  --logfile $dout/log_download_genomes.txt \
  --format fasta \
  --email stijn.wittouck@uantwerpen.be

# the "genbank_..." script outputs zipped and unzipped 
# versions of the genomes; remove the unzipped ones
rm $dout/*.fna
