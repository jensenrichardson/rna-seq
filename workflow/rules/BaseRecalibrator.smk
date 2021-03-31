#configfile: "config/config.yaml"

rule BaseRecalibration:
    input:
        bam="04-SplitCigar/{sample}.splitcigar.bam",
        ref=config["ref_gen"]
    output:
        table="05-BaseRecalibrator/{sample}.table",
    params:
        known_sites="--known-sites " + " --known-sites ".join(config["known_sites"])
    conda:
        "envs/gatk.yaml"
    log:
        "05-BaseRecalibrator/{sample}.log"
    resources:
        cores=16,
	runtime=lambda wildcards, attempt: 10 * attempt
    shell:
        "gatk BaseRecalibrator "
        "-R {input.ref} "
        "-I {input.bam} "
	"{params.known_sites} "
        "-O {output.table} "
        "&> {log}"

