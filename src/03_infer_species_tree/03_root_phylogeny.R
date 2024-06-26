#!/usr/bin/env Rscript

# This script roots the species phylogeny of Lactobacillales using the family
# Listeriaceae as outgroup clade. 

# dependencies: R v4.4.0, tidyverse v2.0.0, ape v5.7.1

library(tidyverse)

fin_tree <- "../../results/representatives/tree/lab.treefile"
fin_genomes <- "../../results/representatives/genomes_metadata.csv"
fout_tree <- "../../results/representatives/tree/lab_rooted.tree"

# read tree and genome metadata
tree <- ape::read.tree(fin_tree)
genomes <- read_csv(fin_genomes, col_types = cols())

# extract assembly accessions of outgroup clade (Listeriaceae)
outgr <- genomes[genomes$gtdb_family == "Listeriaceae", ][["genome"]]

# apply outgroup rooting
tree <- ape::root.phylo(tree, outgroup = outgr, edgelabel = T, resolve.root = T)

# equally divide root branch length
n_tips <- length(tree$tip.label) 
l <- sum(tree$edge.length[tree$edge[, 1] == n_tips + 1])
tree$edge.length[tree$edge[, 1] == n_tips + 1] <- l / 2

# copy the branch support of one rootchild to the other
n_tips <- length(tree$tip.label)
children <- tree %>% {.$edge[.$edge[, 1] == n_tips + 1, 2]}
label <- c(tree$tip.label, tree$node.label)[children] %>% keep(~ . != "")
tree$node.label[children - n_tips] <- label

# write rooted tree
ape::write.tree(tree, file = fout_tree)
