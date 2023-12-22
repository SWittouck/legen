# This script calculates some summary numbers on the LEGEN output files.

metadata_all=../results/all/genomes_metadata.csv
metadata_derep=../results/dereplicated/genomes_species.tsv
pangenome_derep=../results/dereplicated/pangenome/pangenome.tsv

echo "Number of genomes:"
tail -n +2 $metadata_all | wc -l
echo 

echo "Number of species:"
tail -n +2 $metadata_all | cut -d "," -f 2 | sort -u | wc -l 
echo 

echo "Number of high-quality genomes": 
tail -n +2 $metadata_all | awk -F ',' '{ if ($5 >= 0.90) print $1 }' | wc -l 
echo 

echo "Number of species with high-quality genomes:"
cut -f 2 $metadata_derep | sort -u | wc -l
echo

echo "Number of dereplicated genomes:"
cat $metadata_derep | wc -l
echo 

echo "Number of orthogroups in dereplicated genomes:"
cut -f 3 $pangenome_derep | sort -u | wc -l
