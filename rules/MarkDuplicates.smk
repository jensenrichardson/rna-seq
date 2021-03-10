rule MarkDuplicates:
    input:
        "02-mapping/{sample}/{sample}.Aligned.out.bam"
    output:
        "03-markdup/{sample}.markdup.bam"
    log:
        "03-markdup/{sample}.log"
    resources:
        cores: 16
    shell:
        "gatk MarkDuplicatesSpark "
        "-I {input} "
        "-O {output} "
        "&> {log}"