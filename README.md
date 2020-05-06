# Evolutionary Genomics of the Lactobacillus Genus Complex

This repository contains a pipeline that is being developed to study the evolution of the Lactobacillus Genus Complex (LGC) using public genome data.

## Overview of steps

Currently, only the first steps of the pipeline are available: these steps construct a _de novo_ species taxonomy for the LGC by performing single-linkage clustering on pairwise core nucleotide identities (CNIs). Each step is implemented in a separate folder with bash/R/python scripts:

1. __Prepare genomes__: downloading of the genomes, gene prediction, extraction of single-copy core genes (SCGs) and quality control of the genomes.
2. __Cluster genomes__: construction of a core genome supermatrix of the high-quality genomes, calculation of pairwise CNIs and other similarity measures (ANI, TETRA), single-linkage clustering of genomes based on CNIs with a 94% threshold, analysis of cluster "exclusivity" for various CNI clustering cutoffs.
3. __Identify clusters__: gathering of the following information to be able to reconcile the genome clusters with published (sub)species names: NCBI assembly reports (these contain strain names for the genomes), published (sub)species names with their various type strain names (from LPSN, PNU and StrainInfo) and 16S rRNA sequences for published species without type strain genome; extraction of 16S sequences from the genomes; comparison of these sequences against the downloaded type strain 16S sequences.
4. __Analyze representatives__: inference of various types of maximum likelihood trees of the LGC species using one representative genome for each species.

The scripts of this pipeline are meant to be run on a server (could also be a decent desktop computer); they take a while to run and/or work with larger datasets. That being said, not a single script should take longer than ~10 hours to run on a decent desktop computer and only a few scripts take that long. The intention is that the pipeline can be run without need for a cluster.

It should be relatively straightforward to apply the pipeline to any set of up to a few thousand prokaryotic genomes.

## Data analyses based on this pipeline

### Species-level taxonomy of the Lactobacillus Genus Complex

This data analysis is available [here](https://github.com/SWittouck/lacto_species). The results have been published in mSystems:

[Wittouck, Stijn, Sander Wuyts, Conor J Meehan, Vera van Noort, and Sarah Lebeer. 2019. “A Genome-Based Species Taxonomy of the Lactobacillus Genus Complex.” Edited by Sean M Gibbons. MSystems 4 (5): e00264-19. https://doi.org/10.1128/mSystems.00264-19.](https://doi.org/10.1128/mSystems.00264-19)

### Genus-level taxonomy of the Lactobacillus Genus Complex 

This data analysis is available [here](https://github.com/SWittouck/lacto_genera). The results have been published in IJSEM:

[Zheng, J., Wittouck, S., Salvetti, E., Franz, C. M. A. P., Harris, H. M. B., Mattarelli, P., O’Toole, P. W., Pot, B., Vandamme, P., Walter, J., Watanabe, K., Wuyts, S., Felis, G. E., Gänzle, M. G., & Lebeer, S. (2020). A taxonomic note on the genus Lactobacillus: Description of 23 novel genera, emended description of the genus Lactobacillus Beijerinck 1901, and union of Lactobacillaceae and Leuconostocaceae. International Journal of Systematic and Evolutionary Microbiology. https://doi.org/https://doi.org/10.1099/ijsem.0.004107](https://doi.org/10.1099/ijsem.0.004107)

