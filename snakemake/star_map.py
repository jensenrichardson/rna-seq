#!/usr/bin/env python3

# Note Snakemake injection of snakemake.input
import numpy as np
import pandas as pd
from pathlib import Path
import glob
import os

sample_df = pd.read_csv(snakemake.input[0], sep = '\t')

commands = []
genomeDir = snakemake.input[2]
for index, sample in sample_df.iterrows():
    sample_info = sample.dropna().tolist()
    #print(f"Index {index} has info {sample_info}")
    sample_name = sample_info[0]
    readgroups = sample_info[1:]
    #print(f"{sample_name} has readgroups {readgroups}")
    read1s = []
    read2s = []
    for rg in readgroups:
        #print(os.path.join(snakemake.input[1], sample_name + rg) + "*R1*")
        for r1 in glob.glob(os.path.join(snakemake.input[1], rg) + "*R1*"):
            read1s.append(r1)
        for r2 in glob.glob(os.path.join(snakemake.input[1], rg) + "*R2*"):
            read2s.append(r2)
    #print(f"{sample_name} has read 1s of {read1s} and read 2s of {read2s}")
    if not read2s or not read1s:
        print(f"{sample_name} is mising 1: {read1s} or 2: {read2s}")
    files1 = read1s[0]
    files2 = read2s[0]
    if len(files1) > 1:
        for fastq in range(1, len(read1s) - 1):
                files1 = files1 + "," + read1s[fastq]
    if len(files2) > 1:
        for fastq in range(1, len(read2s) - 1):
                files2 = files2 + "," + read2s[fastq]
    rgformat = ""
    for rg in readgroups:
        rgformat = rgformat + " ID: " + rg
    print(f"STAR --runThreadN 20 --genomeDir {genomeDir} --readFilesIn {files1} {files2} --outSAMattrRGline {rgformat} --outSAMtype BAM Unsorted --twopassMode Basic --outFileNamePrefix ./02-mapping/{sample_name}/{sample_name} 1>&2 2>./02-mapping/{sample_name}.log")

path = "/scratch/07467/jwr2735/rna-seq/snakemake/02-mapping.commands"
Path(path).touch()
