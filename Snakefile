configfile: "config/config.yaml"

include: "rules/Star.smk"

rule all: 
	input: "02-mapping.commands"
