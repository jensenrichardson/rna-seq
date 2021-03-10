import pandas as pd
import ast
configfile: "config.yaml"
samples = pd.read_table(config["samples_tsv"], converters={"files": ast.literal_eval}).set_index("sample_name", drop=False)
wildcard_constraints:
    sample ="|".join(samples.index.tolist())

rule STAR_Map:
    input:
        lambda wildcards: samples.loc[wildcards.sample, "files"],
        genome=config["star_genome"]
    params:
        command=lambda wildcards: samples.loc[wildcards.sample, "command"]
    output:
        bam="02-mapping/{sample}/{sample}.Aligned.out.bam"
    log:
        "02-mapping/{sample}/{sample}.Log.final.out",
        "02-mapping/{sample}/{sample}.Log.out",
        "02-mapping/{sample}/{sample}.Log.progress.out",
        "02-mapping/{sample}/{sample}.SJ.out.tab",
        "02-mapping/{sample}/{sample}._STARgenome/sjdbInfo.txt",
        "02-mapping/{sample}/{sample}._STARgenome/sjdbList.out.tab",
        "02-mapping/{sample}/{sample}._STARpass1/Log.final.out",
        "02-mapping/{sample}/{sample}._STARpass1/SJ.out.tab",
    resources:
        runtime=10,
	cores=48,
	mem_mb=63000
    shell:
        "STAR "
        "--runThreadN {resources.cores} " 
        "--genomeDir {input.genome} "
        "{params.command} " 
        "--outSAMtype BAM Unsorted " 
        "--twopassMode Basic "
        "--outFileNamePrefix ./02-mapping/{wildcards.sample}/{wildcards.sample}. &> /dev/null"
