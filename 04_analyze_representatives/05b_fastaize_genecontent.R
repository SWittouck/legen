#!/usr/bin/env Rscript 

# dependencies: R version 3.6.1, tidyverse version 1.2.1, tidygenomes version
# d9f5538d

library(tidyverse)
library(tidygenomes)

din <- "../data_v3/representatives_v3_3/pangenome/OrthoFinder/Orthogroups"
fout <- "../data_v3/representatives_v3_3/pangenome/gene_content.fasta"

# # function taken from tidygenomes v0.1.0 and adapted for OrthoFinder v2.3.3
# read_pangenome <- function(path) {
#   
#   path_orthogroups <- paste0(path, "/Orthogroups.tsv")
#   path_unassigned <- paste0(path, "/Orthogroups_UnassignedGenes.tsv")
#   
#   if (file.exists(path_orthogroups) & file.exists(path_unassigned)) {
#     message("OrthoFinder pagenome files detected")
#   } else {
#     stop("No pangenome file(s) found")
#   }
#   
#   genes_assigned <- 
#     path_orthogroups %>%
#     readr::read_tsv(col_names = T, col_types = cols(.default = "c")) %>%
#     rename(orthogroup = Orthogroup) %>%
#     gather(key = "genome", value = "gene", na.rm = T, - orthogroup) %>%
#     separate_rows(gene, sep = ", ")
#   
#   genes_unassigned <- 
#     path_unassigned %>%
#     readr::read_tsv(col_names = T, col_types = cols(.default = "c")) %>%
#     rename(orthogroup = Orthogroup) %>%
#     gather(key = "genome", value = "gene", na.rm = T, - orthogroup)
#   
#   genes <- bind_rows(genes_assigned, genes_unassigned)
#   
#   genes
#   
# }

#' Fastaize a gene content matrix
#'
#' This function reads a gene content matrix (in the format of an
#' Orthogroups.GeneCount.csv file of OrthoFinder) and converts it to a fasta
#' file with ones and zeros as characters.
#' 
#' Currently, the function removes all constant sites!!!
#' 
#' @param fin Path to input file
#' @param fout Path to output file
#' 
#' @return Null
fastaize_genecontent <- function(din, fout) {
  
  gc_matrix <- 
    read_pangenome(din) %>%
    distinct(genome, orthogroup) %>%
    mutate(present = 1) %>%
    spread(key = orthogroup, value = present, fill = 0) %>%
    `class<-`("data.frame") %>%
    `rownames<-`(.$genome) %>%
    select(- genome) %>%
    as.matrix()
  
  gc_matrix <- gc_matrix[, colSums(gc_matrix) != nrow(gc_matrix)]

  genomes <- rownames(gc_matrix)
  
  file.create(fout)
  
  for (row in seq_along(genomes)) {
    
    genome <- genomes[row]
    write(file = fout, x = paste0(">", genome), append = T)
    write(file = fout, x = gc_matrix[row, ], append = T, ncolumns = 100, sep = "")
    
  }
  
}

fastaize_genecontent(din, fout)
