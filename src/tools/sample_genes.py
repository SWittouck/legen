#!/usr/bin/env python

# This tool selects representative genes from a SCARAP gene table using a second
# table with taxonomic annotation of the genomes. 
# run as: ./sample_genes.py pangenome.tsv genomes.csv sample.tsv 10

# dependencies: pandas, numpy

import argparse
import pandas as pd
import numpy as np

from pathlib import Path

def add_rank(genes, levels, group):
  
    genes["constant"] = "c"
    levels.append("constant")
    genes["rank"] = range(0, len(genes))
    
    for level in levels:
        genes["rank"] = genes\
            .sort_values("rank")\
            .groupby([group, level])\
            .cumcount()
            
    genes = genes.drop(columns = "constant")
    
    return(genes)

if __name__ == "__main__": 
  
    # define commandline arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("pantable", 
        help = "input: SCARAP-style pangenome table (tsv")
    parser.add_argument("genometable", 
        help = "input: genome table (csv)")
    parser.add_argument("sample", 
        help = "output: SCARAP-style gene table (tsv)")
    parser.add_argument("genes_per_orthogroup", type = int, default = 10,
        help = "number of genes to sample per orthogroup (default: 10)")
    
    # parse commandline arguments
    args = parser.parse_args()
    
    # set random seed
    np.random.seed(1991)
    
    # read pangenome and taxonomy tables
    colnames = ["gene", "genome", "orthogroup"]
    genes = pd.read_csv(args.pantable, sep = "\t", names = colnames)
    genomes = pd.read_csv(args.genometable)
    
    # merge tables
    cols = ["gene", "orthogroup", "genome", "species", "gtdb_genus", 
        "gtdb_family"]
    genes = genes.merge(genomes, on = "genome", how = "left").loc[:, cols]
    
    # sample ten genes per orthogroup
    levels = ["genome", "species", "gtdb_genus", "gtdb_family"]
    genes = add_rank(genes, levels, group = "orthogroup")
    genes = genes.query(f"rank < {args.genes_per_orthogroup}")
    
    # write gene table with sampling rank
    cols = ["gene", "genome", "orthogroup"]
    genes.to_csv(args.sample, sep = "\t", index = False, header = False, 
        columns = cols)
