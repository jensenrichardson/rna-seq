rule MarkDuplicates:
    input:
        "02-mapping/{sample}/{sample}.Aligned.sortedByCoord.out.bam"
    output:
        bam=temp("03-markdup/{sample}.markdup.bam"),
        metrics="03-markdup/{sample}.metrics"
    conda:
        "envs/gatk.yaml"
    log:
        "03-markdup/{sample}.log"
    resources:
        cores=16,
	runtime=lambda wildcards, attempt: 45 * attempt
    shell:
        "gatk MarkDuplicates "
        "-I {input} "
        "-O {output.bam} "
        "-M {output.metrics} "
        "&> {log}"
