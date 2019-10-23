#!/usr/bin/env bash

# dependencies: barrnap version 0.9

fin_genomes=../data_v3/quality_control/genome_list.txt
din_genomes=../data_v3/genomes
dout_fastas_rrnas=../data_v3/taxonomy/16S_blast/lgc_rrnas

threads=16

[ -d $dout_fastas_rrnas ] || mkdir -p $dout_fastas_rrnas

# function to run barrnap on one genome
run_barrnap() {
  
  genome=$1
  din_genomes=$2
  dout_fastas_rrnas=$3
  fin_genome=$din_genomes/${genome}*.fna.gz
  
  echo $genome
  gunzip $fin_genome
  barrnap ${fin_genome%.gz} \
    --quiet \
    --outseq $dout_fastas_rrnas/${genome}_rrnas.fasta \
    > $dout_fastas_rrnas/${genome}_rrnas.gff
  gzip ${fin_genome%.gz}

}

# export function so that parallel can find it
export -f run_barrnap

# run barrnap in parallel
parallel \
  --jobs $threads \
  --no-notice \
  run_barrnap {} $din_genomes $dout_fastas_rrnas \
  ::: $(cat $fin_genomes) \
  2>&1 | tee $dout_fastas_rrnas/../log_extract_rrnas.txt
