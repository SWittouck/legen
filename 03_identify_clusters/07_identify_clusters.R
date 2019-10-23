#!/usr/bin/env Rscript 

fout_report <- "../data_v3/taxonomy/cluster_classification_report.html"

rmarkdown::render("identify_clusters.Rmd", output_file = fout_report)
