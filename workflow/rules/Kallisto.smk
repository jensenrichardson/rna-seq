import pandas as pd
import ast
#configfile: "config.yaml"
samples = pd.read_table(config["samples_tsv"], converters={"files": ast.literal_eval}).set_index("sample_name", drop=False)
wildcard_constraints:
    sample ="|".join(samples.index.tolist())

rule Kallisto:
    input:
        files=lambda wildcards: samples.loc[wildcards.sample, "files"],
        genome=config["kallisto_index"]
    output:
        counts="01-Kallisto/{sample}/abundance.tsv"
    conda:
        "envs/star.yaml"
    log:
        info="01-Kallisto/{sample}/run_info.json",
        run="01-Kallisto/{sample}/{sample}.log"
    group: "kallisto"
    resources:
        runtime=lambda wildcards, attempt:30 + (60 * (attempt - 1)),
	cores=42
    shell:
        "kallisto quant "
        "-t {resources.cores} "
        "-i {input.genome} "
        "-o 01-Kallisto/{wildcards.sample} "
        "{input.files} "
        "&> {log.run} "
