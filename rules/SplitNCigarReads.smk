configfile: "config.yaml"

rule SplitNCigarReads:
    input:
        bam="03-markdup/{sample}.markdup.bam",
        ref=config["ref_gen"]
    output:
        bam="04-SplitCigar/{sample}.splitcigar.bam",
        bai="04-SplitCigar/{sample}.splitcigar.bai"
    log:
        "04-SplitCigar/{sample}.log"
    resources:
        cores=16,
	runtime=30
    shell:
        "gatk SplitNCigarReads "
        "-R {input.ref} "
        "-I {input.bam} "
        "-O {output.bam} "
        "&> {log}"

