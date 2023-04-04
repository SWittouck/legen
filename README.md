# Evolutionary Genomics of the Lactic Acid Bacteria

This repository contains a pipeline to study the evolution of the order Lactobacillales using public genome data.

## Dependencies

Software: 

* R v4.2.3
* ProClasp v1.0
* Prodigal v2.6.3
* SCARAP version 1297a09 (and dependencies)
* trimAl 1.4.rev15
* IQ-TREE v1.6.12

R packages:

* tidyverse v2.0.0
* tidygenomes v0.1.3

## The data

genomes_lactobacillales_gtdb-r207.tsv

* metadata of all Lactobacillales genomes that are in release 95 of the GTDB
* downloaded by the script src/lactobacillales/01_download_metadata.R

genomes_lactobacillales_gtdb-r207

* a selection of one high-quality genome per species (for Carnobacteriaceae) or per genus (for non-Carnobacteriaceae) downloaded from the NCBI
* downloaded by the script src/lactobacillales/02_download_genomes.sh

lpsn_gss_2023-03-23.csv

* type strain names and other info for all validly published species, from LPSN
* downloaded from https://lpsn.dsmz.de/downloads (PNU account required)

## How to run? 

Run each script with the script directory as working directory. E.g.:

    cd src/01_prepare_genomes
    ./01_download_metadata.R

## Data analyses based on this pipeline

The following data analyses use the results of version 3 of this pipeline, which considered the family Lactobacillaceae (including the former family Leuconostocaceae). 

### Species-level taxonomy of the Lactobacillus Genus Complex

This data analysis is available [here](https://github.com/SWittouck/lacto_species). The results have been published in mSystems:

[Wittouck, Stijn, Sander Wuyts, Conor J Meehan, Vera van Noort, and Sarah Lebeer. 2019. “A Genome-Based Species Taxonomy of the Lactobacillus Genus Complex.” Edited by Sean M Gibbons. MSystems 4 (5): e00264-19. https://doi.org/10.1128/mSystems.00264-19.](https://doi.org/10.1128/mSystems.00264-19)

### Genus-level taxonomy of the Lactobacillus Genus Complex 

This data analysis is available [here](https://github.com/SWittouck/lacto_genera). The results have been published in IJSEM:

[Zheng, J., Wittouck, S., Salvetti, E., Franz, C. M. A. P., Harris, H. M. B., Mattarelli, P., O’Toole, P. W., Pot, B., Vandamme, P., Walter, J., Watanabe, K., Wuyts, S., Felis, G. E., Gänzle, M. G., & Lebeer, S. (2020). A taxonomic note on the genus Lactobacillus: Description of 23 novel genera, emended description of the genus Lactobacillus Beijerinck 1901, and union of Lactobacillaceae and Leuconostocaceae. International Journal of Systematic and Evolutionary Microbiology. https://doi.org/https://doi.org/10.1099/ijsem.0.004107](https://doi.org/10.1099/ijsem.0.004107)

