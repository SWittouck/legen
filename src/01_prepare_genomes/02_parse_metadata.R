#!/usr/bin/env Rscript

# This script extracts relevant metadata of all genomes, computes an overall
# quality score for each genome and updates the names of species that received
# an sp number by the GTDB but have validly published names.

# dependencies: R v4.2.3, tidyverse v2.0.0

library(tidyverse)

# define paths of input and output
fin_gtdb <- "../../data/genomes_lactobacillales_gtdb-r207.tsv"
fin_lpsn <- "../../data/lpsn_gss_2023-03-23.csv"
dout_results <- "../../results"

# define paths for output files 
dout_results_all <- paste0(dout_results, "/all")
fout_metadata <- paste0(dout_results_all, "/genomes_metadata.csv")
fout_species_updates <- paste0(dout_results_all, "/species_updates.csv")
fout_accessions <- paste0(dout_results_all, "/genomes_accessions.txt")

# create "results/all" folder if it doesn't exist
if (! dir.exists(dout_results)) dir.create(dout_results)
if (! dir.exists(dout_results_all)) dir.create(dout_results_all)

# read full metadata of all genomes
genomes_full <- fin_gtdb %>% read_tsv(col_types = cols())

# read lpsn species table
species_lpsn <- read_csv(fin_lpsn, col_types = cols())

# extract relevant metadata and compute overall quality scores 
genomes <-
  genomes_full %>%
  transmute(
    genome = ncbi_genbank_assembly_accession,
    gtdb_species = str_extract(gtdb_taxonomy, "(?<=s__)[^;]+"), 
    gtdb_genus = str_extract(gtdb_taxonomy, "(?<=g__)[^;]+"), 
    gtdb_family = str_extract(gtdb_taxonomy, "(?<=f__)[^;]+"),
    quality = checkm_completeness / 100 - checkm_contamination / 100,
    checkm_completeness, checkm_contamination, ncbi_isolation_source,
    ncbi_strain_identifiers, gtdb_representative, gc_percentage, genome_size
  )

# create list of Lactobacillales genera according to the GTDB
lab_genera <- unique(genomes$gtdb_genus)

# create a table of lpsn type strain names, filtered down to one species name
# per type strain name
types <-
  species_lpsn %>%
  # we will only consider species names that belong to the GTDB Lactobacillales
  filter(genus_name %in% lab_genera) %>%
  # the species epithet should not be missing
  filter(! is.na(sp_epithet)) %>%
  # the species name should be listed as a "correct name"
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
    lpsn_type = nomenclatural_type, 
    lpsn_species = str_c(genus_name, sp_epithet, sep = " "), 
    lpsn_genus = genus_name, first_published
  ) %>%
  separate_rows(lpsn_type, sep = "; ") %>%
  # for each type strain name, select species name that was published earliest
  group_by(lpsn_type) %>%
  arrange(first_published) %>%
  slice(1) %>%
  ungroup()

cat("Are the lpsn type strain names unique? --> ")
is_unique <- function(x) length(x) == length(unique(x))
if (is_unique(types$lpsn_type)) print("yes") else print("no")

# replace "sp#########" gtdb species epithets by lpsn epithets if available
species_updates <-
  genomes %>%
  # add lpsn species names by connecting through the strain names
  left_join(types, by = c("ncbi_strain_identifiers" = "lpsn_type")) %>%
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

cat("Are the gtdb species names in name update table unique? --> ")
if (is_unique(species_updates$gtdb_species)) print("yes") else print("no")

cat("Are the legen species names in name update table unique? --> ")
if (is_unique(species_updates$species)) print("yes") else print("no")

# write species updates
species_updates %>% write_csv(fout_species_updates)

# create a table with gtdb_species and species (which include the updates)
species <-
  genomes %>%
  distinct(gtdb_species) %>%
  left_join(species_updates, by = "gtdb_species") %>%
  mutate(species = if_else(is.na(species), gtdb_species, species))

# add updated species names to genome metadata table 
genomes <- genomes %>% left_join(species, by = "gtdb_species")

cat("Number of species --> ")
unique(genomes$species) %>% length() %>% print()

# save selected metadata and quality of all genomes
genomes %>%
  write_csv(fout_metadata)
# save accession list of all genomes
genomes %>%
  select(genome) %>%
  write_tsv(fout_accessions, col_names = F)
