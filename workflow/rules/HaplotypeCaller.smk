#configfile: "config.yaml"

rule HaplotypeCaller:
    input:
        bam="06-ApplyRecalibration/{sample}.recalibrated.bam",
	ref=config["ref_gen"],
    log:
        "07-HaplotypeCaller/{sample}.log"
    output:
        vcf="07-HaplotypeCaller/{sample}.hapcall.vcf",
        idx="07-HaplotypeCaller/{sample}.hapcall.vcf.idx"
    conda:
        "envs/gatk.yaml"
    resources:
        cores=16,
	runtime=lambda wildcards, attempt: 60 + 60 * (attempt*2 - 2),
    shell:
        'OMP_NUM_THREADS={resources.cores} gatk --java-options "-Xmx8g" HaplotypeCaller '
        "-R {input.ref} "
        "-I {input.bam} "
        "-O {output.vcf} "
        "&> {log}"
