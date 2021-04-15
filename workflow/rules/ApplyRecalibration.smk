#configfile: "config/config.yaml"

rule ApplyCalibration:
    input:
        bam="04-SplitCigar/{sample}.splitcigar.bam",
        ref=config["ref_gen"],
        table="05-RnaBaseRecalibrator/{sample}.table"
    output:
        bam="06-RnaApplyRecalibration/{sample}.recalibrated.bam",
        bai="06-RnaApplyRecalibration/{sample}.recalibrated.bai"
    conda:
        "envs/gatk.yaml"
    log:
        "06-RnaApplyRecalibration/{sample}.log"
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
