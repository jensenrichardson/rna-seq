#configfile: "config/config.yaml"

rule BaseRecalibration:
    input:
        bam="04-SplitCigar/{sample}.splitcigar.bam",
        ref=config["ref_gen"]
    output:
        table="05-RnaBaseRecalibrator/{sample}.table",
    params:
        known_sites="--known-sites " + " --known-sites ".join(config["known_sites"])
    conda:
        "envs/gatk.yaml"
    log:
        "05-RnaBaseRecalibrator/{sample}.log"
    resources:
        cores=16,
	runtime=lambda wildcards, attempt: 10 * attempt + 20 * (attempt - 1)
    shell:
        "gatk BaseRecalibrator "
        "-R {input.ref} "
        "-I {input.bam} "
	"{params.known_sites} "
        "-O {output.table} "
        "&> {log}"

