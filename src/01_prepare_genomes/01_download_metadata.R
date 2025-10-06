#!/usr/bin/env Rscript

# This script downloads the metadata of all genomes in the GTDB and extracts the
# metadata for the order Lactobacillales.

# dependencies: R, tidyverse

library(tidyverse)

# set higher than default download timeout (5 minutes)
options(timeout = 300)

# define paths of input and output
url_gtdb <- "https://data.gtdb.aau.ecogenomic.org/releases/release226/226.0/bac120_metadata_r226.tsv.gz"
dout_data <- "../../data"

# define paths of individual output files
fout_all <- paste0(dout_data, "/bac120_metadata_r226.tsv.gz")
fout_lacto <- paste0(dout_data, "/lactobacillales_gtdb-r226.tsv.gz")

# create data folder if it doesn't exist
if (! dir.exists(dout_data)) dir.create(dout_data)

# download the tar archive if it doesn't exist
if (! file.exists(fout_all)) download.file(url_gtdb, destfile = fout_all)

# read metadata
genomes_gtdb <- read_tsv(fout_all, col_names = T, col_types = cols())

# extract genomes of the order Lactobacillales and write metadata
genomes_gtdb %>%
  filter(str_extract(gtdb_taxonomy, "o__[^;]+") == "o__Lactobacillales") %>%
  write_tsv(fout_lacto)

# remove temporary files
file.remove(fout_all)
