#!/usr/bin/env Rscript

# This script calculates the core genome GC content of representative genomes of
# Lactobacillaceae species. Core genes are defined as orthogroups that occur
# in a single copy in at least 95% of the genomes. 

# dependencies: R, tidyverse

library(tidyverse)

fin_basecounts <- "../../results/speciesreps/gc_content/basecounts.csv.gz"
fin_pan <- "../../results/speciesreps/pangenome/pangenome.tsv"
fout <- "../../results/speciesreps/gc_content/genomes_gc.csv"

# read base counts and pangenome
counts <- read_csv(fin_basecounts, col_types = cols())
colnames <- c("gene", "genome", "orthogroup")
pan <- read_tsv(fin_pan, col_types = cols(), col_names = colnames)

# merge data into gene table
genes <- full_join(counts, pan, by = c("gene", "genome"))
rm(counts, pan)

# determine core genes
n_genomes <- length(unique(genes$genome))
core <- 
  genes %>%
  count(genome, orthogroup, name = "copies") %>%
  filter(copies == 1) %>%
  count(orthogroup, name = "genomes") %>%
  filter(genomes >= {{n_genomes}} * 0.95) %>%
  pull(orthogroup)

# calculate gc content
genomes <-
  genes %>%
  filter(orthogroup %in% {{core}}) %>%
  group_by(genome) %>%
  summarize(
    core_genes = n(), core_bases = sum(c(A, C, `T`, G)), 
    across(c(A, C, `T`, G), sum), .groups = "drop"
  ) %>%
  mutate(core_gc = (G + C) / (A + C + `T` + G) * 100) %>%
  select(genome, core_genes, core_bases, core_gc)

# write gc table
genomes %>% write_csv(fout, col_names = T)
