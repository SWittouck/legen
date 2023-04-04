#!/usr/bin/env Rscript

# This script dereplicates the genomes of all species based on the per-species
# clustering results. It selects the seeds of the clustering process for species
# with > 1 genome in addition to all genomes in "singleton species".

# dependencies: R v4.2.3, tidyverse v2.0.0

library(tidyverse)

fin_genomes <- "../../results/all/genomes_metadata.csv"
fin_faapaths_all <- "../../results/all/faapaths.txt"
fin_ffnpaths_all <- "../../results/all/ffnpaths.txt"
dio_derep <- "../../results/all/perspecies_high_quality"
dout_derep <- "../../results/dereplicated"

if (! dir.exists(dout_derep)) dir.create(dout_derep)

# read the clusters of the genomes (only for species with > 1 genome)
genomes_clusters <-
  list.dirs(dio_derep, recursive = F) %>%
  str_c("/sample/clusters.tsv") %>%
  map(read_tsv, col_names = c("genome", "cluster"), col_types = cols()) %>%
  reduce(bind_rows)

# write the cluster of each genome (for species with > 1 genome)
genomes_clusters %>%
  write_csv(paste0(dio_derep, "/../genomes_clusters.csv"))

# read the clustering seeds for all species with > 1 genome
seeds <-
  list.dirs(dio_derep, recursive = F) %>%
  str_c("/sample/seeds.txt") %>%
  map(read_lines) %>%
  reduce(c)

# make the selection of dereplicated genomes
dereps <-
  # read the metadata of all genomes
  fin_genomes %>%
  read_csv(col_types = cols()) %>%
  # filter for high quality (because singleton species aren't filtered yet)
  filter(quality >= 0.90) %>%
  # retain singleton species and clustering seeds
  add_count(species, name = "n_genomes") %>%
  filter(n_genomes == 1 | genome %in% seeds) %>%
  select(- n_genomes)

# write the metadata of the dereplicated genomes
dereps %>%
  write_csv(paste0(dout_derep, "/genomes_metadata.csv"))

# write the species of the dereplicated genomes
dereps %>%
  select(genome, gtdb_species) %>% 
  # replace the space with an underscore in the species name
  mutate(gtdb_species = str_replace(gtdb_species," ", "_")) %>%
  write_tsv(paste0(dout_derep, "/genomes_species.tsv"), col_names = F)

# write the faapaths of the dereplicated genomes
fin_faapaths_all %>%
  read_tsv(col_names = c("faapath"), col_types = cols()) %>%
  # extract genome name from faapath
  mutate(genome = str_extract(faapath, "[^/]+(?=.faa.gz)")) %>%
  filter(genome %in% dereps$genome) %>%
  pull(faapath) %>%
  write_lines(paste0(dout_derep, "/faapaths.txt"))

# write the ffnpaths of the dereplicated genomes
fin_ffnpaths_all %>%
  read_tsv(col_names = c("ffnpath"), col_types = cols()) %>%
  # extract genome name from ffnpath
  mutate(genome = str_extract(ffnpath, "[^/]+(?=.ffn.gz)")) %>%
  filter(genome %in% dereps$genome) %>%
  pull(ffnpath) %>%
  write_lines(paste0(dout_derep, "/ffnpaths.txt"))
  