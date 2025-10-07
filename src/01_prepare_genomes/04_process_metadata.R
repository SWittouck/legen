#!/usr/bin/env Rscript

# This script (1) selects relevant metadata of all selected (high quality)
# genomes, (2) removes metadata of genomes for which the download failed, (3)
# updates the names of species that received an sp number by the GTDB but have
# validly published names and (4) selects representative genomes of species.

# dependencies: R, tidyverse

library(tidyverse)

# define paths of input and output
fin_gtdb <- "../../data/lactobacillales_gtdb-r226.tsv.gz"
fin_lpsn <- "../../data/lpsn_gss_2025-10-03.csv"
fin_selected <- "../../data/genomes_selected.txt"
fin_failed <- "../../data/genomes_failed.txt"
dout_results <- "../../results"

# define paths for output files 
dout_all <- paste0(dout_results, "/all")
dout_speciesreps <- paste0(dout_results, "/speciesreps")

# create "results/all" folder if it doesn't exist
if (! dir.exists(dout_results)) dir.create(dout_results)
if (! dir.exists(dout_all)) dir.create(dout_all)
if (! dir.exists(dout_speciesreps)) dir.create(dout_speciesreps)

# read full metadata of all genomes
genomes_full <- fin_gtdb %>% read_tsv(col_types = cols())

# read lpsn species table
species_lpsn <- read_csv(fin_lpsn, col_types = cols())

# read lists of selected genomes and genomes for which the download failed
genomes_selected <- read_lines(fin_selected)
genomes_failed <- read_lines(fin_failed)

# select relevant metadata
genomes <-
  genomes_full %>%
  transmute(
    genome = ncbi_genbank_assembly_accession,
    gtdb_species = str_extract(gtdb_taxonomy, "(?<=s__)[^;]+"), 
    gtdb_genus = str_extract(gtdb_taxonomy, "(?<=g__)[^;]+"), 
    gtdb_family = str_extract(gtdb_taxonomy, "(?<=f__)[^;]+"),
    checkm2_completeness, checkm2_contamination, ncbi_isolation_source,
    ncbi_strain_identifiers, gtdb_representative, gc_percentage, genome_size
  )

# keep selected genomes whose download did not fail
genomes <- 
  genomes %>%
  filter(genome %in% {{genomes_selected}}, ! genome %in% {{genomes_failed}})

# create list of lactobacillales genera according to the gtdb
lacto_genera <- unique(genomes$gtdb_genus)

# create lpsn type strain name table for species names not in gtdb
typenames <-
  species_lpsn %>%
  # form full species names 
  mutate(species_name = str_c(genus_name, sp_epithet, sep = " ")) %>%
  # keep only species names that belong to the gtdb lactobacillales
  filter(genus_name %in% lacto_genera) %>%
  # remove records with missing species epithet
  filter(! is.na(sp_epithet)) %>%
  # remove records of "non-type" subspecies
  filter(is.na(subsp_epithet) | subsp_epithet == sp_epithet) %>%
  # remove species names already present in gtdb
  filter(! species_name %in% genomes$gtdb_species) %>%
  # keep only species names listed as a "correct name"
  filter(str_detect(status, "correct name")) %>%
  # extract the date when the species was first published
  mutate(
    first_published =
      authors %>%
      str_extract_all("[0-9]{4}") %>%
      map_int(~ as.integer(.) %>% sort() %>% first())
  ) %>%
  # convert to one row per type strain name
  transmute(
    lpsn_type_name = nomenclatural_type, 
    lpsn_species = species_name, 
    lpsn_genus = genus_name, first_published
  ) %>%
  separate_rows(lpsn_type_name, sep = "; ") %>%
  # for each type strain name, select species name that was published earliest
  group_by(lpsn_type_name) %>%
  arrange(first_published) %>%
  slice(1) %>%
  ungroup()

cat("Are the lpsn type strain names unique? --> ")
is_unique <- function(x) length(x) == length(unique(x))
if (is_unique(typenames$lpsn_type_name)) print("yes") else print("no")

# replace "sp#########" gtdb species epithets by lpsn epithets if available
species_updates <-
  genomes %>%
  # link assemblies to type names through strain identifiers
  inner_join(typenames, by = c("ncbi_strain_identifiers" = "lpsn_type_name")) %>%
  # list distinct combinations of gtdb and lpsn species names
  distinct(gtdb_species, gtdb_genus, lpsn_species) %>%
  mutate(
    gtdb_genus = str_remove(gtdb_genus, "g__"), 
    gtdb_species_epi = str_extract(gtdb_species, "[^ ]+$")
  ) %>%
  separate(lpsn_species, into = c("lpsn_genus", "lpsn_species_epi")) %>%
  # an lpsn species name should be available
  filter(! is.na(lpsn_species_epi)) %>%
  # the gtdb species epithet should be an sp number
  filter(str_detect(gtdb_species_epi, "^sp[0-9]+$")) %>%
  # the lpsn and gtdb genus names should be the same
  filter(lpsn_genus == gtdb_genus) %>%
  mutate(species = str_c(gtdb_genus, lpsn_species_epi, sep = " ")) %>%
  select(gtdb_species, species)

cat("Number of species updates --> ")
nrow(species_updates) %>% print()

cat("Are the gtdb species names in name update table unique? --> ")
if (is_unique(species_updates$gtdb_species)) print("yes") else print("no")

cat("Are the legen species names in name update table unique? --> ")
if (is_unique(species_updates$species)) print("yes") else print("no")

# create a table with gtdb_species and species (which includes the updates)
species <-
  genomes %>%
  distinct(gtdb_species) %>%
  left_join(species_updates, by = "gtdb_species") %>%
  mutate(species = if_else(is.na(species), gtdb_species, species))

cat("Are all species names unique after implementing the updates? --> ")
if (is_unique(species$species)) print("yes") else print("no")

cat("Number of species --> ")
nrow(species) %>% print()

# add updated species names to genome metadata table 
genomes <- genomes %>% left_join(species, by = "gtdb_species")

# select new representative for species with poor-quality gtdb representative
legen_reprs <- 
  genomes %>%
  group_by(species) %>%
  summarize(
    repr = c(
      genome[gtdb_representative], 
      genome[which.max(checkm2_completeness - checkm2_contamination)]
    )[1], .groups = "drop"
  ) %>%
  pull(repr)
genomes <- genomes %>% mutate(legen_representative = genome %in% legen_reprs)

# write species updates
species_updates %>% write_csv(paste0(dout_all, "/species_updates.csv"))

# write metadata and accessions of all genomes
genomes %>% write_csv(paste0(dout_all, "/genomes.csv"))
genomes %>%
  select(genome) %>%
  write_tsv(paste0(dout_all, "/accessions.txt"), col_names = F)

# write metadata and accessions of species representative genomes
genomes_speciesreps <- genomes %>% filter(legen_representative)
genomes_speciesreps %>% write_csv(paste0(dout_speciesreps, "/genomes.csv"))
genomes_speciesreps %>%
  select(genome) %>%
  write_tsv(paste0(dout_speciesreps, "/accessions.txt"), col_names = F)
