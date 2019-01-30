#!/usr/bin/env Rscript

library(dplyr)
library(readr)
library(stringr)
library(glue)

fin_pairs <- "../data_v3/similarities/genome_pairs.csv.zip"
dout_clusters <- "../data_v3/genome_clusters"
fout_genomes_clusters <- paste0(dout_clusters, "/genomes_clusters.csv")

cutoff_cni <- 0.94

# cluster genomes by single linkage clustering 
# the implementation is non-hierarchical
cluster_genomes_sl <- function(pairs, similarity, cutoff) {
  
  similarity <- enexpr(similarity)
  
  genomes <- unique(c(pairs$genome_1, pairs$genome_2))
  
  clusters <- structure(1:length(genomes), names = genomes)
  
  pairs_same_cluster <- filter(pairs, !! similarity > !! cutoff)
  
  for (row in 1:nrow(pairs_same_cluster)) {
    
    genome_1 <- pairs_same_cluster$genome_1[row]
    genome_2 <- pairs_same_cluster$genome_2[row] 
    
    cluster_1 <- clusters[[genome_1]]
    cluster_2 <- clusters[[genome_2]]
    
    if (cluster_1 != cluster_2) {
      
      clusters[clusters == cluster_2] <- cluster_1
      
    } 
    
  }
  
  tibble(genome = names(clusters), cluster_temp = unname(clusters)) %>%
    mutate(cluster = as.numeric(factor(cluster_temp))) %>%
    mutate(cluster = str_c("cluster ", cluster)) %>%
    select(- cluster_temp)
  
}

# cluster genomes by average linkage hierarchical clustering
# currently not used
cluster_genomes_al <- function(pairs, distance, cutoff) {
  
  distance <- enexpr(distance)
  
  distances_ordered <- 
    pairs %>%
    select(genome_1, genome_2, !! distance) %>%
    add_count(genome_1) %>%
    rename(n_1 = n) %>%
    add_count(genome_2) %>%
    rename(n_2 = n) %>%
    arrange(desc(genome_1), desc(genome_2)) %>%
    select(- n_1, - n_2) 
  
  genomes <- 
    c(
      unique(distances_ordered$genome_1), 
      distances_ordered$genome_2[nrow(distances_ordered)]
    )
  n <- length(genomes)
  
  distances_dist <- 
    distances_ordered %>%
    pull(!! distance) %>%
    structure(Size = n, Labels = genomes, Diag = F, Upper = F, class = "dist")
  
  distances_clust <- hclust(distances_dist, method = "average")
  distances_clust$height <- round(distances_clust$height, digits = 10) # important to mitigate a bug in hclust
  
  cutree(distances_clust, h = cutoff) %>%
    tibble(
      genome = names(.),
      cluster = str_c("cluster", ., sep = " ")
    ) %>%
    select(genome, cluster)
  
}

if (! dir.exists(dout_clusters)) dir.create(dout_clusters, recursive = T)
pairs <- read_csv(fin_pairs)

genomes <- c(pairs$genome_1, pairs$genome_2) %>% unique()
n <- length(genomes)

# cluster genomes using cni similarities
genomes_clusters <- cluster_genomes_sl(pairs, similarity = cni, cutoff = cutoff_cni)

# write table with cni-based genome clusters
write_csv(genomes_clusters, fout_genomes_clusters)
