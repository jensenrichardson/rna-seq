import pandas as pd
import ast

configfile: "config.yaml"
samples = pd.read_table(config["samples_tsv"], converters={"files": ast.literal_eval}).set_index("sample_name", drop=False)
rule all:
	input: expand("03-markdup/{sample}.markdup.bam", sample=samples.to_dict('index'))

include: "rules/Star.smk"
include: "rules/MarkDuplicates.smk"