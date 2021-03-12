configfile: "config.yaml"

rule SplitNCigarReads:
    input:
        bam="03-markdup/{sample}.markdup.bam",
        ref=config["ref_gen"]
    output:
        bam="04-SplitCigar/{sample}.splitcigar.bam",
        bai="04-SplitCigar/{sample}.splitcigar.bam.bai",
        sbi="04-SplitCigar/{sample}.splitcigar.bam.sbi"
    log:
        "04-SplitCigar/{sample}.log"
    resources:
        cores=16,
	runtime=60
    shell:
        "gatk MarkDuplicatesSpark "
        "-R {input.ref} "
        "-I {input.bam} "
        "-O {output.bam} "
        "&> {log}"

