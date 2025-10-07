#!/usr/bin/env Rscript

# This script selects high-quality genomes to download.

# dependencies: R, tidyverse

library(tidyverse)

fin_gtdb <- "../../data/lactobacillales_gtdb-r226.tsv.gz"
fout <- "../../data/genomes_selected.txt"

# read full metadata of all genomes
genomes_full <- fin_gtdb %>% read_tsv(col_types = cols())

# select high quality genomes
accessions <-
  genomes_full %>%
  filter(checkm2_completeness >= 90, checkm2_contamination <= 5) %>%
  pull(ncbi_genbank_assembly_accession)

# write accessions to download
write_lines(accessions, fout)
