#!/usr/bin/env Rscript

library(tidyverse)

fin_genome_pairs <- "../data_v3/similarities/genome_pairs.csv.zip"
fout_exclusiveness <- "../data_v3/genome_clusters/exclusivity.csv"

pairs <- read_csv(fin_genome_pairs)

exclusiveness_curve <- function(pairs, similarity) {
  
  similarity <- enexpr(similarity)
  
  genomes <- 
    tibble(genome = unique(c(pairs$genome_1, pairs$genome_2))) %>%
    mutate(cluster = 1:n())
  
  clusters <- 
    tibble(cluster = genomes$cluster) %>%
    mutate(exclusiveness = 0)
  
  similarity_vector <- numeric(0)
  mean_exclusiveness_vector <- numeric(0)
  n_exclusive_vector <- numeric(0)
  n_clusters_vector <- numeric(0)
  
  pairs <-
    pairs %>%
    rename(similarity = !! similarity) %>%
    arrange(desc(similarity))
  
  for (row in 1:nrow(pairs)) {
    
    print(row)
    
    genome_1 <- pairs$genome_1[row]
    genome_2 <- pairs$genome_2[row] 
    
    cluster_1 <- genomes$cluster[genomes$genome == genome_1]
    cluster_2 <- genomes$cluster[genomes$genome == genome_2]
    
    if (cluster_1 != cluster_2) {
      
      genomes$cluster[genomes$cluster == cluster_2] <- cluster_1
      clusters <- clusters[clusters$cluster != cluster_2, ]
      
      genomes_of_cluster <- genomes$genome[genomes$cluster == cluster_1]
      
      exclusiveness <-
        pairs %>%
        mutate(
          genome_1_in_cluster = genome_1 %in% genomes_of_cluster,
          genome_2_in_cluster = genome_2 %in% genomes_of_cluster
        ) %>%
        filter(genome_1_in_cluster | genome_2_in_cluster) %>%
        mutate(within = genome_1_in_cluster & genome_2_in_cluster) %>%
        summarize(
          min_similarity_within = 
            similarity[within] %>%
            {
              if (length(.) == 0) {1} else {min(.)} 
            },
          max_similarity_between = 
            similarity[! within] %>%
            {
              if (length(.) == 0) {0} else {max(.)} 
            } 
        ) %>%
        mutate(exclusiveness = min_similarity_within - max_similarity_between) %>%
        pull(exclusiveness)
      
      clusters[clusters$cluster == cluster_1, "exclusiveness"] <- exclusiveness
      
      simil <- 
        pairs %>%
        slice(row) %>%
        pull(similarity)
      
      similarity_vector <- c(similarity_vector, simil)
      mean_exclusiveness_vector <- c(mean_exclusiveness_vector, mean(clusters$exclusiveness))
      n_exclusive_vector <- c(n_exclusive_vector, sum(clusters$exclusiveness >= 0))
      n_clusters_vector <- c(n_clusters_vector, nrow(clusters))

    }
    
  }
  
  tibble(
    similarity = similarity_vector,
    mean_exclusiveness = mean_exclusiveness_vector,
    n_exclusive = n_exclusive_vector,
    n_clusters = n_clusters_vector
  )
  
}

exclusiveness_curve(pairs, cni) %>%
  write_csv(fout_exclusiveness)
