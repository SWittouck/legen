# Evolutionary Genomics of the Lactobacillus Genus Complex: pipeline

This repository contains a pipeline that I am developing to study the evolution of the Lactobacillus Genus Complex (LGC) using public genome data. Currently, only the first steps of the pipeline are available: these steps construct a _de novo_ species taxonomy for the LGC by performing single-linkage clustering on pairwise core nucleotide identities (CNIs). Each step is implemented in a separate folder with bash/R/python scripts: 

1) __Prepare genomes__: downloading of the genomes, gene prediction, extraction of single-copy core genes (SCGs) and quality control of the genomes. 
2) __Cluster genomes__: construction of a core genome supermatrix of the high-quality genomes, calculation of pairwise CNIs and other similarity measures (ANI, TETRA), single-linkage clustering of genomes based on CNIs with a 94% threshold, analysis of cluster "exclusivity" for various CNI clustering cutoffs. 
3) __Identify clusters__: gathering of the following information to be able to reconcile the genome clusters with published (sub)species names: NCBI assembly reports (these contain strain names for the genomes), published (sub)species names with their various type strain names (from LPSN, PNU and StrainInfo) and 16S rRNA sequences for published species without type strain genome; extraction of 16S sequences from the genomes; comparison of these sequences against the downloaded type strain 16S sequences. 
4) __Infer species tree__: inference of a maximum likelihood tree of the LGC species using one representative genome for each species and 100 SCGs.

The scripts of this pipeline are meant to be run on a server (could also be a decent desktop computer); they take a while to run and/or work with larger datasets. That being said, not a single script should take longer than ~10 hours to run on a decent desktop computer and only a few scripts take that long. The intention is that the pipeline can be run without need for a supercomputer. The actual data analysis of the results of this pipeline is implemented in [this repository](https://github.com/SWittouck/legen_data_analysis); it contains very lightweight Rmarkdown scripts that can be run fast and locally and without requiring much disk space.

It should be relatively straightforward to apply the pipeline to any set of up to a few thousand prokaryotic genomes. 
