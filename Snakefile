import pandas as pd
import ast

configfile: "config.yaml"
samples = pd.read_table(config["samples_tsv"], converters={"files": ast.literal_eval}).set_index("sample_name", drop=False)

include: "rules/Star.smk"

rule all:
	input: expand("02-mapping/{sample}/{sample}.Aligned.out.bam", sample=samples.to_dict('index'))
