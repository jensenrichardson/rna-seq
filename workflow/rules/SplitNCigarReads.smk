#configfile: "config.yaml"

rule SplitNCigarReads:
    input:
        bam="03-markdup/{sample}.markdup.bam",
        ref=config["ref_gen"]
    output:
        bam="04-SplitCigar/{sample}.splitcigar.bam",
        bai="04-SplitCigar/{sample}.splitcigar.bai"
    conda:
        "envs/gatk.yaml"
    log:
        "04-SplitCigar/{sample}.log"
    resources:
        cores=16,
	runtime=lambda wildcards, attempt: 60 * attempt + 120 * (attempt - 1)
    shell:
        "gatk SplitNCigarReads "
        "-R {input.ref} "
        "-I {input.bam} "
        "-O {output.bam} "
        "&> {log}"

