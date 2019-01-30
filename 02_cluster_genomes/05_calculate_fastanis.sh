#!/bin/bash

# dependency: fastANI version 1.1

# This script splits the fastANI run in batches of reference genomes
# to save memory. When the memory is overloaded, fastANI will abort
# without error message. If this happens, reduce the batch size.

fin_genome_list=../data_v3/quality_control/genome_list.txt
din_genomes=../data_v3/genomes
dout_fastanis=../data_v3/similarities/fastanis

threads=16
batch_size=900

for dout in $dout_fastanis/{genome_paths,logs,fastanis_per_batch} ; do
  [ -d $dout ] || mkdir -p $dout
done

# make files with genome paths for fastANI:
# - all.txt: all genome paths
# - txt files with genome paths per batch of genomes
i=0
for genome in $(cat $fin_genome_list) ; do
  batch=batch$((i / $batch_size))
  fout_genome_paths_batch=$dout_fastanis/genome_paths/$batch.txt
  [ ! $((i % batch_size)) -eq 0 ] || cp /dev/null $fout_genome_paths_batch
  genome_path=$din_genomes/${genome}*
  echo $genome_path >> $fout_genome_paths_batch
  echo $genome_path >> $dout_fastanis/genome_paths/all.txt
  i=$((i + 1))
done

# FastANI takes query and reference genomes.
# Approach to save memory: split the reference genomes in batches and run 
# once per batch; use all genomes as queries in each run.
# (The other way around saves no memory.)
for fin_batch in $dout_fastanis/genome_paths/batch*.txt ; do

  re="(batch[0-9]+)"
  [[ $fin_batch =~ $re ]] && batch=${BASH_REMATCH[1]}

  echo $batch

  fastANI \
    --queryList $dout_fastanis/genome_paths/all.txt \
    --refList $fin_batch \
    --output $dout_fastanis/fastanis_per_batch/$batch.txt \
    --threads $threads \
    2>&1 | tee $dout_fastanis/logs/$batch.txt

done

# Concatenate the results of each batch in one large file. 
cat $dout_fastanis/fastanis_per_batch/*.txt \
  > $dout_fastanis/fastanis.txt
