#!/usr/bin/env Rscript

# This script aggregates the annotations of sampled genes on the orthogroup
# level.

# dependencies: R, tidyverse

library(tidyverse)

dio <- "../../results/speciesreps/annotation/"
fin_sample <- paste0(dio, "sample.tsv.gz")
fin_annot <- paste0(dio, "annotation/lacto.emapper.annotations.tsv.gz")
fout_annot <- paste0(dio, "orthogroups_functions.csv")
fout_log <- paste0(dio, "orthogroup_functions.log")

# read the necessary gene tables
colnames <- c("gene", "genome", "orthogroup")
genes_orthogroups <- 
  fin_sample %>%
  read_tsv(col_types = cols(), col_names = colnames)
genes_annot <- 
  fin_annot %>%
  read_tsv(col_types = cols(), comment = "##") %>%
  rename(gene = `#query`)

# aggregate functional annotations on the orthogroup level
mode.char <- function(x) {
  mode <- 
    x %>%
    table() %>%
    {.[which.max(.)]} %>%
    names()
  if (is.null(mode)) return(as.character(NA))
  mode
}
votes <- function(x) max(c(table(x), 0))
orthogroups <- 
  genes_orthogroups %>%
  left_join(genes_annot, by = "gene") %>%
  mutate(cog = str_extract(eggNOG_OGs, "^[^,]+")) %>%
  select(
    orthogroup, cog, category = COG_category, name = Preferred_name,
    descr = Description
  ) %>%
  mutate(across(c(cog, category, name, descr), ~ na_if(., "-"))) %>%
  replace_na(list(category = "S")) %>%
  group_by(orthogroup) %>%
  summarize(
    genes_sampled = n(), 
    cog_mode = mode.char(cog), cog_votes = votes(cog), 
    category_mode = mode.char(category), category_votes = votes(category), 
    name_mode = mode.char(name), name_votes = votes(name),
    descr_mode = mode.char(descr), descr_votes = votes(descr)
  )

# write some statistics to a log file
"number of orthogroups: " %>%
  paste0(nrow(orthogroups)) %>% 
  write(fout_log)
n_known <- sum(orthogroups$category_mode != "S")
"number of orthogroups with known function: " %>%
  paste0(n_known) %>%
  write(fout_log, append = T)

# write aggregated functional annotations
write_csv(orthogroups, fout_annot)
