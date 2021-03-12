configfile: "config.yaml"

rule HaplotypeCaller:
    input:
        bam="06-ApplyRecalibration/{sample}.recalibrated.bam",
	ref=config["ref_gen"],
    log:
        "07-HaplotypeCaller/{sample}.log"
    output:
        vcf="07-HaplotypeCaller/{sample}.hapcall.vcf",
        idx="07-HaplotypeCaller/{sample}.hapcall.vcf.idx"
    resources:
        cores=16,
	runtime=360,
    shell:
        'OMP_NUM_THREADS={resources.cores} gatk --java-options "-Xmx8g" HaplotypeCaller '
        "-R {input.ref} "
        "-I {input.bam} "
        "-O {output.vcf} "
        "&> {log}"
