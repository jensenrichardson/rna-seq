configfile: "config.yaml"

rule ApplyCalibration:
    input:
        bam="04-SplitCigar/{sample}.splitcigar.bam",
        ref=config["ref_gen"],
        table="05-BaseRecalibrator/{sample}.table"
    output:
        bam="06-ApplyRecalibration/{sample}.recalibrated.bam",
        bai="06-ApplyRecalibration/{sample}.recalibrated.bai"
    log:
        "06-ApplyRecalibration/{sample}.log"
    resources:
        cores=16,
	runtime=lambda wildcards, attempt: 20 * attempt
    shell:
        "gatk ApplyBQSR "
        "-R {input.ref} "
        "-I {input.bam} "
	"--bqsr-recal-file {input.table} "
        "-O {output.bam} "
        "&> {log}"
