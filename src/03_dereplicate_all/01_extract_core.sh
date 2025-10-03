# This script identifies the top 100 single-copy core genes in all genomes of 
# Lactobacillales. 

# dependencies: SCARAP v0.4.0 (bde4a13)

fin_faapaths_repr=../../results/representatives/faapaths.txt
fin_faapaths_all=../../results/all/faapaths.txt
dout_repr=../../results/representatives
dout_all=../../results/all

threads=32

# build a profile database of the top 100 single-copy core genes 
scarap build $fin_faapaths_repr $dout_repr/pangenome/pangenome.tsv \
  $dout_repr/core100 -p 0.9 -m 100 -t $threads
  
# identify the top 100 core genes in all genomes 
scarap search $fin_faapaths_all $dout_repr/core100 $dout_all/core100 \
  -t $threads
