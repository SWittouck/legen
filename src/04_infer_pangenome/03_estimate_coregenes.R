#!/usr/bin/env Rscript

# This script estimates the orthogroup occurrences and genomes completenesses
# for genomes of species with five or more genomes.

# dependencies: R v4.2.3, tidyverse v2.0.0, tidygenomes v0.1.3

library(tidyverse)
library(tidygenomes)

source("estimation_functions.R")

fin_pan <- "../../results/dereplicated/pangenome/pangenome.tsv"
fin_genomes <- "../../results/dereplicated/genomes_metadata.csv"
fout_orthogroups <- "../../results/dereplicated/orthogroups_occurrence.csv"
fout_genomes <- "../../results/dereplicated/genomes_completeness.csv"

min_genomes <- 10

# read pangenome 
genes <- 
  fin_pan %>% 
  read_tsv(col_names = c("gene", "genome", "orthogroup"), col_types = cols())

# read genome metadata
genomes <- fin_genomes %>% read_csv(col_types = cols())

# how many genomes do we have of the species? 
genomes %>%
  count(species, name = "n_genomes") %>%
  filter(n_genomes > 1) %>%
  ggplot(aes(x = rank(- n_genomes, ties.method = "first"), y = n_genomes)) +
  geom_hline(yintercept = 10, lty = "dashed", col = "grey") +
  geom_point() +
  theme_bw()

# estimate orthogroup occurrences per species with at least n genomes
pan_list <-
  genes %>%
  left_join(genomes %>% select(genome, species), by = "genome") %>%
  # filter(species %in% unique(species)[1:150]) %>%
  split(.$species) %>%
  map2(., names(.), function(genes, species) {
    if (length(unique(genes$genome)) < min_genomes) return(NULL)
    print(species)
    pan <-
      genes %>%
      as_tidygenomes() %>%
      add_pangenome_estimates() %>%
      add_genome_measures()
    pan$orthogroups <-
      pan$orthogroups %>%
      mutate(species = {{species}})
    pan$genomes <-
      pan$genomes %>%
      mutate(gn_orthogroups_est = gn_orthogroups / completeness_est) %>%
      mutate(species = {{species}})
    pan
  }) %>%
  keep(~ ! is.null(.))

orthogroups <-
  pan_list %>%
  map("orthogroups") %>%
  reduce(bind_rows)

genomes <-
  pan_list %>%
  map("genomes") %>%
  reduce(bind_rows)

# save orthogroup occurrences and genome completenesses
orthogroups %>% write_csv(fout_orthogroups)
genomes %>% write_csv(fout_genomes)
