# This script calculates some summary numbers on the LEGEN output files.

all=../data/lactobacillales_gtdb-r226.tsv.gz
selected=../results/all/genomes.csv
speciesreps=../results/speciesreps/genomes.csv
dereps=../results/dereps/genomes.csv

pan_speciesreps=../results/speciesreps/pangenome/pangenome.tsv
pan_dereps=../results/dereps/pangenome/pangenome.tsv

echo "Total genomes:"
zcat $all | tail -n +2 | wc -l
echo 

echo "Total species:"
zcat $all | tail -n +2 | cut -f 20 | sort -u | wc -l 
echo 

echo "High-quality (= selected) genomes:"
tail -n +2 $selected | wc -l
echo 

echo "High-quality (= selected) species:"
tail -n +2 $speciesreps | wc -l
echo 

echo "Orthogroups in pangenome of species representatives:"
cut -f 3 $pan_speciesreps | sort -u | wc -l
echo

echo "Dereplicated genomes:"
tail -n +2 $dereps | wc -l
echo 

echo "Orthogroups in pangenome of dereplicated genomes:"
cut -f 3 $pan_dereps | sort -u | wc -l
echo
