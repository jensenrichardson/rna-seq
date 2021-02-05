configfile: "config/config.yaml"

rule parse_samples:
	input:
		config["fastq_dir"]
	output:
		protected("config/samples.tsv")
	script:
		"../scripts/parse_samples.py"
