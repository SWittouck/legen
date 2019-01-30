#!/usr/bin/env Rscript

# dependency: tidyorthogroups version 0.0.0.9000

# to install tiydorthogroups:
# install.packages(devtools)
# devtools::install_github("SWittouck/tidyorthogroups", dep = F)

library(dplyr)
library(tidyr)
library(readr)
library(stringr)
library(tidyorthogroups)

din_similarities <- "../data_v3/similarities"
fin_cnis <- paste0(din_similarities, "/cnis/cnis.distmat")
fin_anis <- paste0(din_similarities, "/fastanis/fastanis.txt")
fin_tetras <- paste0(din_similarities, "/tetras/TETRA_correlations.tab")
fout_pairs <- paste0(din_similarities, "/genome_pairs.csv")

gca_regex <- "GC[AF]_[0-9]+\\.[0-9]"

# CNIs

cnis_unique <- read_phylip_distmat(fin_cnis, include_diagonal = F, skip = 8)

cnis_unique <- 
  cnis_unique %>%
  rename(genome_1 = sequence_1, genome_2 = sequence_2) %>%
  mutate(cni = 1 - distance / 100) %>%
  select(genome_1, genome_2, cni)

# ANI distances

anis <- 
  read_tsv(fin_anis, col_names = F) %>%
  rename(genome_path_1 = X1, genome_path_2 = X2, ani = X3)

anis <- 
  anis %>%
  mutate(genome_1 = str_extract(genome_path_1, !! gca_regex)) %>%
  mutate(genome_2 = str_extract(genome_path_2, !! gca_regex)) %>%
  select(genome_1, genome_2, ani)

anis_1 <- 
  anis %>%
  filter(genome_1 > genome_2) %>%
  select(genome_1, genome_2, ani_1 = ani)

anis_2 <- 
  anis %>%
  filter(genome_2 > genome_1) %>%
  mutate(genome_1_temp = genome_2, genome_2_temp = genome_1) %>%
  select(genome_1 = genome_1_temp, genome_2 = genome_2_temp, ani_2 = ani)

anis_unique <- 
  full_join(anis_1, anis_2) %>%
  mutate(ani_mean = cbind(ani_1, ani_2) %>% rowMeans(na.rm = T))

anis_unique <- 
  anis_unique %>%
  mutate(ani = ani_mean / 100) %>%
  select(genome_1, genome_2, ani)

# TETRA distances

tetras_untidy <- read_tsv(fin_tetras, col_names = T)

tetras <- 
  tetras_untidy %>%
  rename(genome_1 = X1) %>%
  gather(key = "genome_2", value = "tetra", - genome_1) 

tetras <- 
  tetras %>%
  mutate(genome_1 = str_extract(genome_1, !! gca_regex)) %>%
  mutate(genome_2 = str_extract(genome_2, !! gca_regex))

tetras_1 <- 
  tetras %>%
  filter(genome_1 > genome_2) %>%
  select(genome_1, genome_2, tetra_1 = tetra)

tetras_2 <- 
  tetras %>%
  filter(genome_2 > genome_1) %>%
  rename(genome_1_temp = genome_2, genome_2_temp = genome_1) %>%
  select(genome_1 = genome_1_temp, genome_2 = genome_2_temp, tetra_2 = tetra)

tetras_unique <- 
  full_join(tetras_1, tetras_2) %>%
  select(genome_1, genome_2, tetra = tetra_1)

# Merge distances and write result

pairs <- 
  cnis_unique %>%
  left_join(anis_unique) %>%
  left_join(tetras_unique) %>%
  mutate(noise = runif(nrow(.), min = - 0.01, max = 0.01)) %>%
  mutate(ani = ifelse(is.na(ani), 0.7 + noise, ani)) %>%
  select(- noise)

write_csv(pairs, fout_pairs)
zip(str_c(fout_pairs, ".zip"), fout_pairs)
file.remove(fout_pairs)
