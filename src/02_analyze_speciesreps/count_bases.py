#!/usr/bin/env python

# This script calculates base frequencies in a set of genomes. 
# run as: ./count_bases.py ffndir acclist > basecounts.csv

# dependencies: python, pandas, biopython

import argparse
import gzip
import pandas as pd
import sys

from Bio import SeqIO
from collections import Counter
from pathlib import Path

def count_bases(ffnfile):

    genes = []
    with gzip.open(ffnfile, mode = "rt") as f:
        for record in SeqIO.parse(f, "fasta"):
            c = Counter(record.seq)
            c["gene"] = record.name
            genes.append(c)
            
    genes = pd.DataFrame(genes)
    genes = genes[["gene", "A", "C", "T", "G"]]
    
    return(genes)
  
def count_bases_multi(ffndir, accessions): 

    genes = []
    
    for accession in accessions:
      
        print(accession, file = sys.stderr)
        
        ffnfile = Path(ffndir) / f"{accession}.ffn.gz"
        genes_new = count_bases(ffnfile)
        genes_new["genome"] = accession
        genes_new = genes_new[["gene", "genome", "A", "C", "T", "G"]]
        genes.append(genes_new)
        
    genes = pd.concat(genes, ignore_index = True)
    
    return(genes)

if __name__ == "__main__":
  
    # define commandline arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("ffndir", help = "the directory with ffn files")
    parser.add_argument("acclist", help = "the file with accession numbers")
    
    # parse commandline arguments
    args = parser.parse_args()
    ffndir = args.ffndir
    with open(args.acclist, "rt") as f:
        accessions = f.read().splitlines()
    
    # count bases and write to stdout
    genes = count_bases_multi(ffndir, accessions)
    genes.to_csv(sys.stdout, index = False)
