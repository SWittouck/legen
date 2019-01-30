#!/usr/bin/env bash

# dependency: blast version 2.6.0

fin_query=../data_v3/taxonomy/rrnas_16S.fasta
fin_db=../data_v3/taxonomy/type_16s_genes_unidentified_names.fasta
dout_blast=../data_v3/taxonomy/blast

threads=16

[ -d $dout_blast ] || mkdir -p $dout_blast

makeblastdb \
  -dbtype nucl \
  -in $fin_db \
  -out $dout_blast/type_16s_genes \
  -title type_16s_genes \
  -parse_seqids \
  2>&1 | tee $dout_blast/log_makeblastdb.txt

blastn \
  -query $fin_query \
  -strand plus \
  -task blastn \
  -db $dout_blast/type_16s_genes \
  -outfmt 6 \
  -out $dout_blast/hits_to_type_16s_genes.tsv \
  -num_threads $threads \
  2>&1 | tee $dout_blast/log_blastn.txt
