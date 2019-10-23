#!/usr/bin/env Rscript

# dependency: tidytypes version 0.1.0

# Run this script with two command line arguments: the PNU username and
# password. For example: ./02_get_type_genomes_and_16s_genes.R
# some_adress@stuff.com mypassword.

library(tidyverse)
library(tidytypes)

fin_assembly_reports <- "../data_v3/taxonomy/genomes_assembly_reports.csv"
fin_genome_list <- "../data_v3/quality_control/genome_list.txt"
dout_taxonomy <- "../data_v3/taxonomy/type_strains"

genera <- c("Lactobacillus", "Pediococcus", "Leuconostoc", "Weissella", "Oenococcus", "Fructobacillus")

args <- commandArgs(trailingOnly = T)
username <- args[1]
password <- args[2]

if (! dir.exists(dout_taxonomy)) dir.create(dout_taxonomy, recursive = T)

# download names from PNU

names_pnu <- pnu_names(genera, username, password)
save(names_pnu, file = paste0(dout_taxonomy, "/lgc_names_pnu.rda"))

# download names from LPSN

names_lpsn <- lpsn_names(genera)
save(names_lpsn, file = paste0(dout_taxonomy, "/lgc_names_lpsn.rda"))

# download extra strain names for LPSN names from StrainInfo

names_lpsn_extended <-
  names_lpsn %>%
  mutate(si = map(name, si_name)) %>%
  mutate(type_strain_name_si = map(si, "type_strain_names")) %>%
  mutate(type_strain_name = map2(type_strain_name, type_strain_name_si, ~ c(.x, .y) %>% unique())) %>%
  select(- si, - type_strain_name_si)
save(names_lpsn_extended, file = paste0(dout_taxonomy, "/lgc_names_lpsn_extended.rda"))

# combine names and make sure they are unique

names_combined <-
  bind_rows(
    names_lpsn_extended %>% mutate(evidence = "lpsn"),
    names_pnu %>% mutate(evidence = "pnu")
  ) %>%
  correct_subspecies() %>%
  summarize_names()
save(names_combined, file = paste0(dout_taxonomy, "/lgc_names.rda"))

# compile list of type strain names and make sure they are unique

type_strain_names <-
  names_combined %>%
  select(name, species, type_strain_name) %>%
  unnest(type_strain_name) %>%
  distinct() %>%
  filter(! is.na(type_strain_name)) %>%
  filter(str_detect(type_strain_name, "[a-zA-Z]")) %>%
  group_by(type_strain_name) %>%
  slice(1) %>%
  ungroup()

# read assembly reports of genomes (to see their strain names)

genomes_ncbi <- read_csv(fin_assembly_reports)

# read list with genomes that pass qc

genomes_of_quality <- read_lines(fin_genome_list)

# compile table with type genomes

genomes_type <- 
  genomes_ncbi %>%
  select(genome, strain_name) %>%
  filter(! is.na(strain_name)) %>%
  filter(str_detect(strain_name, "[a-zA-Z]")) %>%
  filter(genome %in% genomes_of_quality) %>%
  inner_join(
    type_strain_names %>% 
      rename(strain_name = type_strain_name) %>%
      mutate_at("strain_name", str_remove, "N$") %>%
      distinct(strain_name, name)
  ) %>%
  mutate(species = str_extract(name, "^[^ ]+ [^ ]+"))
paste0("number of type genomes: ", nrow(genomes_type)) %>% print
paste0("number of species with type strain genome: ", genomes_type$species %>% unique %>% length) %>% print

# save table with type genomes

write_csv(genomes_type, paste0(dout_taxonomy, "/lgc_genomes_type.csv"))

# compile list of unidentified names (names with zero type genomes)

names_unidentified <-
  names_combined %>%
  filter(! name %in% genomes_type$name) 

# download type 16S rRNA gene sequences for unidentified names

fasta <- 
  names_unidentified %>%
  select(name, species, type_sixteen_s) %>%
  unnest(type_sixteen_s) %>%
  mutate(sequence = map_chr(type_sixteen_s, genbank_sequence, max_attempts = 3)) %>%
  mutate(sequence = if_else(str_length(sequence) > 5000, as.character(NA), sequence))

fasta %>%
  filter(! is.na(sequence)) %>%
  mutate_at("name", str_replace_all, " ", "_") %>%
  mutate(header = glue::glue(">{name}")) %>%
  mutate(fasta = str_c(header, sequence, sep = "\n")) %>%
  mutate_at("fasta", str_trim) %>%
  pull(fasta) %>%
  write_lines(paste0(dout_taxonomy, "/type_16S_genes_unidentified_names.fasta"))
