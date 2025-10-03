# This script infers the pangenome of representative genomes for species
# of Lactobacillales. 

# dependencies: SCARAP v0.4.0 (bde4a13)

fin_faapaths=../../results/representatives/faapaths.txt
dout=../../results/representatives

threads=32

# infer the pangenome of the representative genomes 
scarap pan $fin_faapaths $dout/pangenome -t $threads

