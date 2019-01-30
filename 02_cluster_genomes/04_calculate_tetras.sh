#!/bin/bash

# dependency: pyani
# remark: after installing pyani, I changed python to
# python3 in the shebang line in the
# average_nucleotide_identity.py script

din_genomes=../data_v3/genomes
dout=../data_v3/similarities

threads=16

[ -d $dout ] || mkdir -p $dout

# unzip all genomes
# I timed it: non-parallel is fastest
for fin_genome in $din_genomes/*.gz ; do
  gunzip $fin_genome
done

# run pyani on all genomes
# remerk: the outdir should not exist yet
average_nucleotide_identity.py \
  --method TETRA \
  --workers $threads \
  --verbose \
  --indir $din_genomes \
  --outdir $dout/tetras \
  2>&1 | tee $dout/log_calculate_tetras.txt

# rezip all genomes
# I timed it: parallel is fastest (by factor 10)
parallel \
  --jobs $threads \
  --no-notice \
  gzip {} \
  ::: ${din_genomes}/*.fna

