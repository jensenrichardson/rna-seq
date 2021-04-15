import pandas as pd
import ast
import os
#configfile: "config.yaml"
samples = pd.read_table(config["samples_tsv"], converters={"files": ast.literal_eval}).set_index("sample_name", drop=False)
wildcard_constraints:
    sample ="|".join(samples.index.tolist())

rule FastQC:
    input:
        expand("{fastq_dir}/{{fastq}}.fastq", fastq_dir = os.path.normpath(config['fastq_dir']))
    output:
        zip="00-FastQC/{fastq}_fastqc.zip",
        html="00-FastQC/{fastq}_fastqc.html"
    conda:
        "envs/star.yaml"
    log:
        "00-FastQC/{fastq}.log"
    resources:
        runtime=lambda wildcards, attempt:60 + (60 * (attempt - 1)),
        cores=1
    group: "fastqc"
    shell:
        "fastqc "
        "-o 00-FastQC/ "
        "{input} "
        "&> {log} "
