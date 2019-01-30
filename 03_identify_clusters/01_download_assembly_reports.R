#!/usr/bin/env Rscript

# dependency: rentrez version 1.2.1

library(dplyr)
library(readr)
library(stringr)
library(purrr)
library(rentrez)
library(xml2)

din_genomes <- "../data_v3/genomes"
dout_reports <- "../data_v3/taxonomy"

if (! dir.exists(dout_reports)) dir.create(dout_reports, recursive = T)

batch_size <- 10
max_attempts <- 8

# Downloads assembly reports for a list of genomes in one batch. 
download_reports_one_batch <- function(accessions, max_attempts = 3) {
  
  reports <- NULL
  attempt <- 1
  
  while(is.null(reports) && attempt <= max_attempts) {
    
    print(paste0("attempt ", attempt))
    
    try ({
      
      query <- str_c(accessions, collapse = "|")
      uids <- entrez_search(db = "assembly", term = query, use_history = T)
      reports <- 
        entrez_summary(db = "assembly", id = uids$ids) %>%
        map(modify_at, "gb_bioprojects", as.list) %>%
        transpose() %>%
        do.call(what = tibble)
      
    })
    
    attempt <- attempt + 1
    
  }
  
  reports %>%
    filter(assemblyaccession %in% accessions) 
  
}

# Downloads assembly reports for a list of genomes in batches. 
download_reports <- function(accessions, batch_size = 10, max_attempts = 3) {
  
  n <- length(accessions)
  
  reports <- tibble()
  
  for (i in 0:(n %/% batch_size)) {
    
    start <- i * batch_size
    print(start)
    
    reports_new <- 
      download_reports_one_batch(
        genomes[(start + 1):(start + batch_size)],
        max_attempts = max_attempts
      )
    print(paste0("reports found: ", nrow(reports_new)))
    reports <- bind_rows(reports, reports_new)
    
  }
  
  reports %>%
    mutate_all(simplify, .type = character(1)) 
  
}

# Download the isolation source for a biosample id
isolation_source <- function(accession, max_attempts = 3) {
  
  print(accession)
  
  isolation_source <- NULL
  attempt <- 1
  
  while(is.null(isolation_source) && attempt <= max_attempts) {
    
    print(paste0("attempt ", attempt))
    
    try ({
      
      search_res <- rentrez::entrez_search(db = "biosample", term = accession)
      record <- rentrez::entrez_fetch(db = "biosample", id = search_res$ids, rettype = "xml")
      
      isolation_source <-
        record %>%
        read_xml() %>%
        xml_find_all("//Attribute[contains(@attribute_name, 'isolation')]") %>%
        xml_text()
      
    })
    
    attempt <- attempt + 1
    
  }
  
  if(length(isolation_source) != 1) return("")
  
  isolation_source
  
}

genomes <- 
  list.files(din_genomes, pattern = "\\.fna\\.gz") %>%
  str_extract("^[^_]+_[^_]+")

genomes_reports_raw <-
  genomes %>%
  download_reports(batch_size = batch_size, max_attempts = max_attempts) %>%
  mutate(isolation_source = map_chr(biosampleid, isolation_source, max_attempts = 5))

save(genomes_reports_raw, file = paste0(dout_reports, "/genomes_assembly_reports_raw.rda"))

genomes_reports <-
  genomes_reports_raw %>%
  mutate(strain_name = map_chr(biosource, c("infraspecieslist", "sub_value"), .default = NA)) %>%
  mutate_at("strain_name", str_remove, "type strain:") %>%
  mutate_at("strain_name", str_squish) %>%
  select(
    genome = assemblyaccession, strain_name, name = organism, species = speciesname, 
    fromtype, wgs, isolation_source
  )

write_csv(genomes_reports, path = paste0(dout_reports, "/genomes_assembly_reports.csv"))
