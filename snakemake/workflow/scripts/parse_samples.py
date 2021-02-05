#!/usr/bin/env python3
# This script is responsible for parsing a directory of
# fastq samples to produce a tsv that is easy to manage
# with snakemake.
import numpy as np
import pandas as pd
from os import listdir
from os.path import isfile, join
from pathlib import Path

# note that there is a snakemake object that will have 
# the directory of the fastq files as
# snakemake.input[0]

directory = snakemake.input[0]
fastq_files = [f for f in listdir(directory) if isfile(join(directory, f))]

for file in fastq_files:
    print(file)

sample_tsv_path = "/scratch/07467/jwr2735/rna-seq/snakemake/config/samples.tsv"
Path(sample_tsv_path).touch()
