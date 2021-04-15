rule KallistoCut:
    input:
        "01-Kallisto/{sample}/abundance.tsv"
    output:
        "01-Kallisto/{sample}/abundance_counts_only.tsv"
    group: "kallisto"
    resources:
        runtime=2
    shell:
        "cut -f 1,4 {input} > {output} "
