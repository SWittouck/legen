#!/usr/bin/env python3

from Bio import SeqIO
import glob
import re

din_fastas_rrnas = "../data_v3/taxonomy/fastas_rrnas"
fout_fasta_rrnas_16S = "../data_v3/taxonomy/rrnas_16S.fasta"

# make list of all fasta files in the rrnas folder
fins_fastas_rrnas = glob.glob(din_fastas_rrnas + "/*.fasta")

# go through sequences and keep the 16S ones
records_16S = []
for fin_fasta_rrna in fins_fastas_rrnas:
    genome = re.search("GC[FA]_[^_]+", fin_fasta_rrna).group(0)
    print(genome)
    with open(fin_fasta_rrna) as hin_fasta_rrna:
        seqs = SeqIO.parse(hin_fasta_rrna, "fasta")
        for seq in seqs:
            if seq.id.startswith("16S_rRNA"):
                seq.id = genome + "::" + seq.id
                seq.description = ""
                records_16S.append(seq)

# write 16S sequences
with open(fout_fasta_rrnas_16S, "w") as hout_fasta_rrnas_16S:
    SeqIO.write(records_16S, fout_fasta_rrnas_16S, "fasta")
