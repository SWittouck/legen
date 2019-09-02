#!/usr/bin/env bash

# dependency: trimal 1.4.rev15

fin_supermatrix_nucs=\
../data_v3/representatives_v3_2/supermatrix/supermatrix_nucs.fasta
fout_supermatrix_nucs_trimmed=\
../data_v3/representatives_v3_2/supermatrix/supermatrix_nucs_trimmed.fasta

# trim supermatrix: remove columns where > 1% of the sequences has a gap
trimal \
  -in $fin_supermatrix_nucs \
  -out $fout_supermatrix_nucs_trimmed \
  -gt 0.99 \
  -keepheader
