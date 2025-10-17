# Evolutionary Genomics of *Lactobacillales*

This repository contains a pipeline to study the evolution of the order *Lactobacillales* using public genome data.

## How to run? 

Step 1: clone this repository: 

    git clone https://github.com/swittouck/legen.git

Step 2: create folders for data and results: 

    cd legen
    mkdir data results
    
Step 3: download type strain names of validly published species from the LPSN:

1. Go to https://lpsn.dsmz.de/downloads
2. Log in (create an account if you do not yet have one)
3. Download the genera, species and subspecies (GSS) list (e.g. "lpsn_gss_2025-10-03.csv")
4. Put the list in the data folder

Step 4: install all [dependencies](#dependencies): 

    conda env create -f ./environment.yml -p ./env
    conda activate ./env
    
Step 5: install the EggNOG database (required for functional annotation): 

    download_eggnog_data.py --data_dir data/eggnog

Step 6: run all scripts in `src` in the order indicated by the file/folder names. Run each script directly from its parent directory. E.g.:

    cd src/01_prepare_genomes
    ./01_download_metadata.R

Step 7: deactivate the conda environment: 

    conda deactivate

## Dependencies

See [environment.yml](environment.yml). 

## LEGEN versions 

| LEGEN version | GTDB version | year |
| :------------ | :----------- | :--- |
| v3            | /            | 2018 | 
| v4            | r207         | 2022 |
| v5            | r226         | 2025 | 

## The data

lactobacillales_gtdb-r226.tsv

* metadata of all *Lactobacillales* genomes that are in release 226 of the GTDB
* downloaded by the script src/01_prepare_genomes/01_download_metadata.R

genomes_selected.txt

* assembly accessions of high-quality genomes
* created by the script src/01_prepare_genomes/02_select_genomes.R

lactobacillales_gtdb-r226

* assemblies (.fna files) of selected genomes
* downloaded by the script src/01_prepare_genomes/03_download_genomes.sh

genomes_failed.txt

* assembly accessions of selected genomes whose download failed
* created by the script src/01_prepare_genomes/03_download_genomes.sh 

lpsn_gss_2025-10-03.csv

* type strain names and other info for all validly published species, from LPSN
* downloaded from https://lpsn.dsmz.de/downloads (PNU account required)

eggnog

* the EggNOG database, version 5

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

