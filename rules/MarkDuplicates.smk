rule MarkDuplicates:
    input:
        "02-mapping/{sample}/{sample}.Aligned.sortedByCoord.out.bam"
    output:
        bam="03-markdup/{sample}.markdup.bam",
        metrics="03-markdup/{sample}.metrics"
    log:
        "03-markdup/{sample}.log"
    resources:
        cores=16,
	runtime=25
    shell:
        "gatk MarkDuplicates "
        "-I {input} "
        "-O {output.bam} "
        "-M {output.metrics} "
        "&> {log}"
