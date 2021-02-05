configfile: "config/config.yaml"

rule STAR_Map:
	input:
		config["samples_tsv"],
		config["fastq_dir"],
		config["star_genome"]
	output: "02-mapping.commands"
	script:
		"../scripts/star_map.py"
