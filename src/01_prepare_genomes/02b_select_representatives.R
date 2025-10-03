#!/usr/bin/env Rscript

# This scripts selects GTDB representative genomes of all species and writes out
# their metadata, assembly accessions, ffnpaths and faapaths.

# dependencies: R v4.2.3, tidyverse v2.0.0

library(tidyverse)

fin_genomes <- "../../results/all/genomes_metadata.csv"
din_faas <- "../../results/all/genes/faas"
din_ffns <- "../../results/all/genes/ffns"
dout <- "../../results/representatives"

# define paths of output files 
fout_metadata <- paste0(dout, "/genomes_metadata.csv")
fout_accessions <- paste0(dout, "/genomes_accessions.txt")
fout_ffnpaths <- paste0(dout, "/ffnpaths.txt")
fout_faapaths <- paste0(dout, "/faapaths.txt")

# create output folder if it doesn't exist
if (! dir.exists(dout)) dir.create(dout)

# read the metadata of all genomes
genomes <- read_csv(fin_genomes, col_types = cols())

# select gtdb representatives of species
selected <- genomes %>% filter(gtdb_representative)
  
# write metadata of representatives
selected %>% write_csv(fout_metadata)

# write accession list of representatives
selected %>% select(genome) %>% write_tsv(fout_accessions, col_names = F)

# write ffnpaths of representatives
selected$genome %>%
  str_c(din_ffns, "/", ., "*") %>%
  Sys.glob() %>%
  write_lines(fout_ffnpaths)

# write faapaths of representatives
selected$genome %>%
  str_c(din_faas, "/", ., "*") %>%
  Sys.glob() %>%
  write_lines(fout_faapaths)
