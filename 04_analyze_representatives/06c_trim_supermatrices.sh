#!/usr/bin/env bash

# dependency: trimal 1.4.rev15

din_supermatrices=../data_v3/representatives_v3_3/supermatrix

# trim protein supermatrix: remove columns where > 10% of the sequences has a 
# gap
trimal \
  -in $din_supermatrices/supermatrix_aas.fasta \
  -out $din_supermatrices/supermatrix_aas_trimmed.fasta \
  -gt 0.90 \
  -keepheader

# trim dna supermatrix: remove columns where > 10% of the sequences has a 
# gap
trimal \
  -in $din_supermatrices/supermatrix_nucs.fasta \
  -out $din_supermatrices/supermatrix_nucs_trimmed.fasta \
  -gt 0.90 \
  -keepheader
