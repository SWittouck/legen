#!/usr/bin/env bash 

cd ../results
tar czf legen.tar.gz \
  all/genomes_metadata.csv \
  representatives/tree/lab.treefile \
  dereplicated/genomes_metadata.csv \
  dereplicated/genomes_completeness.csv \
  dereplicated/orthogroups_occurrence.csv \
  dereplicated/pangenome/pangenome.tsv