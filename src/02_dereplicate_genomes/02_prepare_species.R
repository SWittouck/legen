#!/usr/bin/env Rscript

# This script creates one folder per species that has more than two genomes. It
# splits the core100 genes, ffnpaths and faapaths per species and stores them in
# these folders. It does all this for the full genome dataset, and then again
# but only for genomes with a quality >= 90%.

# dependencies: R v4.2.3, tidyverse v2.0.0

library(tidyverse)

fin_genomes <- "../../results/all/genomes_metadata.csv"
fin_ffnpaths <- "../../results/all/ffnpaths.txt"
fin_faapaths <- "../../results/all/faapaths.txt"
fin_core100_genes <- "../../results/all/core100/genes.tsv"
dout_all <- "../../results/all/perspecies_all"
dout_high_quality <- "../../results/all/perspecies_high_quality"

if (! dir.exists(dout_all)) dir.create(dout_all)
if (! dir.exists(dout_high_quality)) dir.create(dout_high_quality)

# read the necessary data
genomes <- read_csv(fin_genomes, col_types = cols())
ffnpaths <- 
  read_lines(fin_ffnpaths) %>%
  tibble(ffnpath = ., genome = str_extract(., "[^/]+(?=.ffn.gz)"))
faapaths <- 
  read_lines(fin_faapaths) %>%
  tibble(faapath = ., genome = str_extract(., "[^/]+(?=.faa.gz)"))
core100_genes <- 
  fin_core100_genes %>%
  read_tsv(col_names = c("gene", "genome", "orthogroup"), col_types = cols())

# prepare genome dataset 1: genomes of species that have > 1 genome
genomes_set1 <- 
  genomes %>%
  select(species, genome, quality) %>%
  # only retain species with more than one genome
  add_count(species, name = "n_genomes") %>%
  filter(n_genomes > 1) %>% 
  select(- n_genomes) %>%
  # replace the space with an underscore in the species name
  mutate(species = str_replace(species," ", "_")) %>%
  # add ffnpaths
  left_join(ffnpaths, by = "genome") %>%
  # add faapaths
  left_join(faapaths, by = "genome") %>%
  # remove genomes with missing faa or ffn files
  # (can happen if assemblies are suppressed on ncbi)
  filter(! is.na(ffnpath))

# prepare genome dataset 2: same as dataset 1, but only after quality filtering
genomes_set2 <- 
  genomes_set1 %>%
  # retain only genomes with quality >= 0.90
  filter(quality >= 0.90) %>%
  # only retain species with more than one genome
  add_count(species, name = "n_genomes") %>%
  filter(n_genomes > 1) %>%
  select(- n_genomes)

# create folder per species and write ffnpaths and faapaths for dataset 1
genomes_set1 %>%
  # split table per species
  split(f = .$species) %>%
  # create folder per species and write ffnpaths and faapaths
  walk2(., names(.), function(genomes, species) {
    dout_sp <- paste0(dout_all, "/", species)
    if (! dir.exists(dout_sp)) dir.create(dout_sp)
    write_lines(genomes$ffnpath, paste0(dout_sp, "/ffnpaths.txt"))
    write_lines(genomes$faapath, paste0(dout_sp, "/faapaths.txt"))
  })

# create folder per species and write ffnpaths and faapaths for dataset 2
genomes_set2 %>%
  # split table per species
  split(f = .$species) %>%
  # create folder per species and write ffnpaths and faapaths
  walk2(., names(.), function(genomes, species) {
    dout_sp <- paste0(dout_high_quality, "/", species)
    if (! dir.exists(dout_sp)) dir.create(dout_sp)
    write_lines(genomes$ffnpath, paste0(dout_sp, "/ffnpaths.txt"))
    write_lines(genomes$faapath, paste0(dout_sp, "/faapaths.txt"))
  })

# write the core100 genes per species for dataset 1
core100_genes %>%
  right_join(genomes_set1, by = "genome") %>%
  # create list with core100 genes per species
  {split(.[, c("gene", "genome", "orthogroup")], .$species)} %>%
  # write core100 genes to their respective species folders
  walk2(., names(.), function(genes, species) {
    dout_sp <- paste0(dout_all, "/", species)
    write_tsv(genes, paste0(dout_sp, "/core100.tsv"), col_names = F)
  })

# write the core100 genes per species for dataset 2
core100_genes %>%
  right_join(genomes_set2, by = "genome") %>%
  # create list with core100 genes per species
  {split(.[, c("gene", "genome", "orthogroup")], .$species)} %>%
  # write core100 genes to their respective species folders
  walk2(., names(.), function(genes, species) {
    dout_sp <- paste0(dout_high_quality, "/", species)
    write_tsv(genes, paste0(dout_sp, "/core100.tsv"), col_names = F)
  })
