#!/usr/bin/env Rscript

# This script selects one genome per species, using number of missing SCGs (=
# single-copy core genes) as criterium. 
# Remark: an "orthogroup" is a gene family, so SCGs are orthogroups. 
# Input:
# - fin_scg_matrix: input csv file with SCGs in genomes
# - fin_genomes_clusters: input csv file with columns genome and cluster

library(readr)
library(dplyr)
library(tidyr)

fin_scg_matrix <- "../data_v3/similarities/cnis/scg_matrix.csv"
fin_genomes_clusters <- "../data_v3/genome_clusters/genomes_clusters.csv"
fout_representatives <- "../data_v3/representatives_v3_3/representatives.txt"

scg_matrix <- read_csv(fin_scg_matrix)
genomes_clusters <- read_csv(fin_genomes_clusters)

genes <- 
  scg_matrix %>%
  gather(value = "gene", key = "orthogroup", - genome)

genomes_selected <- 
  genes %>%
  group_by(genome) %>%
  summarize(n_ogs_missing = gene %>% is.na() %>% sum()) %>%
  left_join(genomes_clusters) %>%
  group_by(cluster) %>%
  arrange(n_ogs_missing) %>%
  slice(1) %>%
  ungroup() %>%
  pull(genome)

writeLines(genomes_selected, fout_representatives)
