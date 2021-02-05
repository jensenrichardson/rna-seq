#!/usr/bin/env python3
# This script is responsible for parsing a directory of
# fastq samples to produce a tsv that is easy to manage
# with snakemake.
import numpy as np
import pandas as pd
from os import listdir
from os.path import isfile, join
from pathlib import Path
import re

# note that there is a snakemake object that will have 
# the directory of the fastq files as
# snakemake.input[0]

class Sample:
    name = ""
    readgroups = []

    def __init__(self):
        self.name = ""
        self.readgroups = ""
    def __init__(self, name):
        self.name = name

directory = snakemake.input[0]
fastq_files = [f for f in listdir(directory) if isfile(join(directory, f))]

# Establishes list of samples
samples = []
for file in fastq_files:
    sample_name = re.search('^.+?(?=_)', file).group(0)
    sample = Sample(sample_name)
    name_match = re.compile(f"^{sample.name}")
    samples if any(name_match.match(sample.name) for sample in samples) else samples.append(sample)
#print(samples)
#print(len(samples))
samples.sort(key = lambda s : s.name)

# Establishes readgroups
for sample in samples:
    match_r1 = re.compile(f"^{sample.name}.+?(?=R1)")
    match_r2 = re.compile(f"^{sample.name}.+?(?=R2)")
    readgroups = [match_r1.match(file).group(0) for file in fastq_files if match_r1.match(file) and any(match_r2.match(file) for file in fastq_files)]
    #print(f"{sample.name} has readgroups {readgroups}")
    if not readgroups:
        print(f"{sample.name} has no readgroups. {readgroups}")
    sample.readgroups = readgroups

data = {}
for sample in samples:
    data[sample.name] = np.array(sample.readgroups)
#print(data)

#df = pd.DataFrame(dict([ (k, pd.Series(v)) for k,v in data.items() ]))
#df = df.transpose()
#
#sample_tsv_path = "/scratch/07467/jwr2735/rna-seq/snakemake/config/samples.tsv"
#df.to_csv(sample_tsv_path, sep = '\t')
