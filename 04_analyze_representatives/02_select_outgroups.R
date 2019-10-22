#!/usr/bin/env Rscript 

# dependencies: R version 3.6.1 and tidyverse version 1.2.1

library(tidyverse)

fout_genomes <- "../data_v3/outgroups/outgroup_genomes.tsv"
fout_metadata <- "../data_v3/outgroups/bac120_metadata_r89.tsv"
url <- "https://data.ace.uq.edu.au/public/gtdb/data/releases/release89/89.0/bac120_metadata_r89.tsv"

if (! dir.exists("input")) dir.create("input")
if (! dir.exists("data")) dir.create("data")

download.file(url, destfile = fout_metadata)

ranks <- c( "domain", "phylum", "class", "order", "family", "genus", "species")

genomes_parks <-
  read_tsv(fout_metadata) %>%
  mutate(genome = str_remove(accession, "^.{3}")) %>%
  separate(gtdb_taxonomy, sep = ";", into = ranks) %>%
  mutate_at(ranks, str_remove, "^.{3}")

genomes_parks %>%
  filter(order == "Lactobacillales", family != "Lactobacillaceae") %>%
  select(genome, genus, species, checkm_completeness, checkm_contamination) %>%
  filter(checkm_contamination < 5) %>%
  group_by(genus) %>%
  filter(checkm_completeness == max(checkm_completeness)) %>%
  slice(1) %>%
  ungroup() %>%
  select(genome, species) %>%
  write_tsv(fout_genomes, col_names = F)
