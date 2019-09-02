#!/usr/bin/env bash

# dependency: raxmlHPC-PTHREADS-AVX version 8.2.11

fin_supermatrix_nucs=\
../data_v3/representatives_v3_2/supermatrix/supermatrix_nucs_trimmed.fasta
dout_tree=\
../data_v3/representatives_v3_2/phylogeny

threads=16

[ -d $dout_tree ] || mkdir -p $dout_tree

# Infer tree using raxml-ng; not used at the moment because no possibility 
# for rapid bootstrapping.
# raxml-ng \
#   --all \
#   --msa $fin_supermatrix_nucs \
#   --model GTR+FO+G \
#   --tree pars{10} \
#   --bs-trees 100 \
#   --threads $threads \
#   --prefix ${dout_tree}/lgc

# convert relative path to absolute path
fin_supermatrix_nucs=$(realpath $fin_supermatrix_nucs)
# cd to output directory; raxml can't handle an output path
cd $dout_tree

# Infer tree using the PTHREADS parallelized version of RAxML, with AVX vector
# instructions. 
raxmlHPC-PTHREADS-AVX \
  -T $threads \
  -f a \
  -m GTRCAT \
  -p 1991 \
  -x 1991 -N autoMRE \
  -s $fin_supermatrix_nucs \
  -n lgc
