# Evolutionary Genomics of *Lactobacillales*

This repository contains a pipeline to study the evolution of the order *Lactobacillales* using public genome data.

## How to run? 

Step 1: clone this repository: 

    git clone https://github.com/swittouck/legen.git

Step 2: install all [dependencies](#dependencies). 

Step 3: create folders for data and results: 

    cd legen
    mkdir data results
    
Step 4: download type strain names of validly published species from [the LPSN](https://lpsn.dsmz.de/downloads) and put them in `data`. 

Step 5: run all scripts in `src` in the order indicated by the file/folder names. Run each script directly from its parent directory. E.g.:

    cd src/01_prepare_genomes
    ./01_download_metadata.R

## Dependencies

Software: 

* R v4.2.3
* ProClasp v1.0
* Prodigal v2.6.3
* SCARAP v0.4.0
* trimAl 1.4.rev15
* IQ-TREE v1.6.12

R packages:

* tidyverse v2.0.0
* tidygenomes v0.1.3
* ape v5.7.1

## The data

genomes_lactobacillales_gtdb-r207.tsv

* metadata of all *Lactobacillales* genomes that are in release 207 of the GTDB
* downloaded by the script src/lactobacillales/01_download_metadata.R

genomes_lactobacillales_gtdb-r207

* a selection of one high-quality genome per species (for *Carnobacteriaceae*) or per genus (for non-*Carnobacteriaceae*) downloaded from the NCBI
* downloaded by the script src/lactobacillales/02_download_genomes.sh

lpsn_gss_2023-03-23.csv

* type strain names and other info for all validly published species, from LPSN
* downloaded from https://lpsn.dsmz.de/downloads (PNU account required)

## Data analyses based on this pipeline

### Demonstration of SCARAP and analysis of orthogroup fixation frequency

This analysis was based on v4 of LEGEN and is available in [the pangenome-toolkit repository](https://github.com/SWittouck/pangenome-toolkit). The results have been published in Bioinformatics: 

> Wittouck, S., Eilers, T., Van Noort, V., & Lebeer, S. (2024). SCARAP: Scalable cross-species comparative genomics of prokaryotes. Bioinformatics, 41(1), btae735. https://doi.org/10.1093/bioinformatics/btae735

### Genus-level taxonomy of *Lactobacillaceae*

This analysis was based on v3 of LEGEN and is available in [the lacto_genus repository](https://github.com/SWittouck/lacto_genera). The results have been published in IJSEM:

> Zheng, J., Wittouck, S., Salvetti, E., Franz, C. M. A. P., Harris, H. M. B., Mattarelli, P., O’Toole, P. W., Pot, B., Vandamme, P., Walter, J., Watanabe, K., Wuyts, S., Felis, G. E., Gänzle, M. G., & Lebeer, S. (2020). A taxonomic note on the genus Lactobacillus: Description of 23 novel genera, emended description of the genus Lactobacillus Beijerinck 1901, and union of Lactobacillaceae and Leuconostocaceae. International Journal of Systematic and Evolutionary Microbiology, 70(4), 2782–2858. https://doi.org/10.1099/ijsem.0.004107

### Species-level taxonomy of *Lactobacillaceae*

This analysis was based on v3 of LEGEN and is available in [the lacto_species repository](https://github.com/SWittouck/lacto_species). The results have been published in mSystems:

> Wittouck, S., Wuyts, S., Meehan, C. J., Van Noort, V., & Lebeer, S. (2019). A genome-based species taxonomy of the lactobacillus genus complex. mSystems, 4(5), e00264-19. https://doi.org/10.1128/mSystems.00264-19

