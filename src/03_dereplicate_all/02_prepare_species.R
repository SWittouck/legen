#!/usr/bin/env Rscript

# This script splits the core gene table of all genomes into a core gene table
# per species. 

# dependencies: R, tidyverse

library(tidyverse)

fin_genes <- "../../results/all/core100/genes.tsv"
fin_genomes <- "../../results/all/genomes.csv"
dout <- "../../results/all/core100_perspecies"

if (! dir.exists(dout)) dir.create(dout)

# read genome and gene tables
colnames <- c("gene", "genome", "orthogroup")
genes <- fin_genes %>% read_tsv(col_names = colnames, col_types = cols())
genomes <- fin_genomes %>% read_csv(col_names = T, col_types = cols())

# write core gene table per species
genes %>%
  left_join(select(genomes, genome, species), by = "genome") %>%
  group_split(species) %>%
  walk(~ {
    species <- unique(.$species) %>% str_replace(" ", "_")
    select(., gene, genome, orthogroup) %>%
      write_tsv(paste0(dout, "/", species, ".tsv"), col_names = F)
  })
