#!/usr/bin/env bash 

cd ../results
tar czf legen_v4-1.tar.gz \
  README.md \
  all/genomes_metadata.csv \
  representatives/genomes_metadata.csv \
  representatives/pangenome/pangenome.tsv \
  representatives/tree/lab.treefile \
  dereplicated/genomes_completeness.csv \
  dereplicated/genomes_metadata.csv \
  dereplicated/orthogroups_occurrence.csv \
  dereplicated/pangenome/pangenome.tsv