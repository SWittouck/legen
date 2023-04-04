#!/usr/bin/env Rscript

# This script downloads the metadata of all genomes in the GTDB and extracts the
# metadata for the order Lactobacillales.

# dependencies: R v4.2.3, tidyverse v2.0.0

library(tidyverse)

# define paths of input and output
url_gtdb <- "https://data.gtdb.ecogenomic.org/releases/release207/207.0/bac120_metadata_r207.tar.gz"
dout_data <- "../../data"

# define paths of individual output files
fout_tmp_tar <- paste0(dout_data, "/genomes_lactobacillales_gtdb-r207.tar.gz")
fout_tmp_tsv <- paste0(dout_data, "/genomes_lactobacillales_gtdb-r207.tsv")
fout_lab <- paste0(dout_data, "/genomes_lactobacillales_gtdb-r207.tsv")

# create data folder if it doesn't exist
if (! dir.exists(dout_data)) dir.create(dout_data)

# download the tar archive if it doesn't exist
if (! file.exists(fout_tmp_tar)) {
  download.file(url_gtdb, destfile = fout_tmp_tar)
}

# untar the archive and read it
untar(fout_tmp_tar, exdir = dout_data)
genomes_gtdb <- read_tsv(fout_tmp_tsv)

# extract genomes of the order Lactobacillales and write metadata
genomes_gtdb %>%
  filter(str_extract(gtdb_taxonomy, "o__[^;]+") == "o__Lactobacillales") %>%
  write_tsv(fout_lab)

# remove temprary files
file.remove(fout_tmp_tar)
file.remove(fout_tmp_tsv)
