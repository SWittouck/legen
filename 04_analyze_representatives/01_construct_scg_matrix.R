#!/usr/bin/env Rscript

# This script selects one genome per species, using number of missing SCGs (=
# single-copy core genes) as criterium. In addition, it selects the best n SCGs,
# using number of missing genomes as a criterium. In effect, it produces a
# "submatrix" of the SCG matrix.
# Remark: an "orthogroup" is a gene family, so SCGs are orthogroups. 
# Input:
# - fin_scg_matrix: input csv file with SCGs in genomes
# - fin_genomes_clusters: input csv file with columns genome and cluster
# - fout_scg_matrix_subset: output csv file to write subsetted SCG matrix to

library(readr)
library(dplyr)
library(tidyr)

fin_scg_matrix <- "../data_v3/similarities/cnis/scg_matrix.csv"
fin_genomes_clusters <- "../data_v3/genome_clusters/genomes_clusters.csv"
fout_scg_matrix_subset <- "../data_v3/representatives_v3_2/scg_matrix.csv"

n_orthogroups <- 100

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

scgs_selected <- 
  genes %>%
  filter(genome %in% !! genomes_selected) %>%
  group_by(orthogroup) %>%
  summarize(n_genomes_missing = gene %>% is.na() %>% sum()) %>%
  arrange(n_genomes_missing) %>%
  slice(1:(!! n_orthogroups)) %>%
  pull(orthogroup)

scg_matrix_subset <- 
  scg_matrix %>%
  filter(genome %in% !! genomes_selected) %>%
  select(genome, one_of(scgs_selected))

write_csv(scg_matrix_subset, fout_scg_matrix_subset)
