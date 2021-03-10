import pandas as pd
import ast
configfile: "config.yaml"
samples = pd.read_table(config["samples_tsv"], converters={"files": ast.literal_eval}).set_index("sample_name", drop=False)
wildcard_constraints:
    sample ="|".join(samples.index.tolist())

rule STAR_Map:
    input:
        lambda wildcards: samples.loc[wildcards.sample, "files"]
    params:
        command=lambda wildcards: samples.loc[wildcards.sample, "command"]
    output:
        bam="02-mapping/{sample}.bam"
    threads: workflow.cores 0.8
    shell:
        "STAR "
        "--runThreadN {threads} " 
        "{params.command} " 
        "--outSAMtype BAM Unsorted " 
        "--twopassMode Basic " 
        "--outFileNamePrefix ./02-mapping/${wildcards.sample}/${wildcards.sample}"