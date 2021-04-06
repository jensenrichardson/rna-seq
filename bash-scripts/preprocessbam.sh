#!/bin/bash

ref=./req-files/refGenome/GRCh38.p7.genome.fa

# ensure that we have the reference
if test -f $ref; then
	echo "Found reference"
else
	echo "Could not locate reference files. Make sure you have the zip I provided and that it is unzipped."
	exit 1
fi

# set the known sites location
known=./req-files/known-sites/

# makes sure that there's an input
if  [ $# -eq 0 ]; then
	echo No input!
	exit 1
fi

# import the bam file
bam=$1

# get the name of the sample to be used in all the stuff after. 
sample=$2


# STEP 6 - BASE RECALIBRATION


if [ ! -f ./06-baserecalibration/$sample.baserecal.table ]; then
echo "./req-files/gatk/gatk BaseRecalibrator -I ./05-markduplicates/$sample.markdup.bam -R $ref --known-sites ./req-files/known-sites/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz --known-sites ./req-files/known-sites/Homo_sapiens_assembly38.dbsnp138.vcf -O ./06-baserecalibration/$sample.baserecal.table 1>&2 2>./06-baserecalibration/$sample.baserecal.gatk.log" >> "06-baserecal.commands"
fi

if [ $? -ne 0 ]
then
	echo Base recalibration failed! Check the log file!
	exit 6
fi


# STEP 7 - APPLY BASE RECALIBRATION


if [ ! -f ./07-ApplyBaseRecalibration/$sample.recalibrated.bam ]; then
echo "./req-files/gatk/gatk ApplyBQSR -R $ref -I ./05-markduplicates/$sample.markdup.bam --bqsr-recal-file ./06-baserecalibration/$sample.baserecal.table -O ./07-ApplyBaseRecalibration/$sample.recalibrated.bam 1>&2 2>./07-ApplyBaseRecalibration/$sample.applybqsr.log" >> "07-applybaserecal.commands"
fi

if [ $? -ne 0 ]
then
	echo Applying base recalibration failed! Check the log file!
	exit 7
fi


if [ ! -f ./07.5-AnalyzeRecalibration/$sample.basepostrecal.table ]; then
echo "./req-files/gatk/gatk BaseRecalibrator -I ./07-ApplyBaseRecalibration/$sample.recalibrated.bam -R $ref --known-sites ./req-files/known-sites/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz --known-sites ./req-files/known-sites/Homo_sapiens_assembly38.dbsnp138.vcf -O ./07.5-AnalyzeRecalibration/$sample.basepostrecal.table 1>&2 2>./07.5-AnalyzeRecalibration/$sample.basepostrecal.gatk.log" >> "07.5.1-rebaserecal.commands"
fi

if [ $? -ne 0 ]
then
	echo Analyzing recalibrated data failed! Check the log file!
	exit 7
fi



if [ ! -f ./07.5-AnalyzeRecalibration/$sample.recalibrationresults.pdf ]; then
echo "./req-files/gatk/gatk AnalyzeCovariates -before ./06-baserecalibration/$sample.baserecal.table -after ./07.5-AnalyzeRecalibration/$sample.basepostrecal.table -plots ./07.5-AnalyzeRecalibration/$sample.recalibrationresults.pdf 1>&2 2>./07.5-AnalyzeRecalibration/$sample.recalanalyze.log" >> "07.5.2-analyzerecal.commands"
fi

if [ $? -ne 0 ]
then
	echo Unable to analyze covariates! Check the log file!
	exit 7
fi




# STEP 8 - Beginning mutation detection

if [ ! -f ./08-Mutect/$sample.rawmutcall.vcf ]; then
echo "./req-files/gatk/gatk Mutect2 -R $ref -I ./07-ApplyBaseRecalibration/$sample.recalibrated.bam -O ./08-Mutect/$sample.rawmutcall.vcf --f1r2-tar-gz ./08-Mutect/$sample.f1r2.tar.gz 1>&2 2>./08-Mutect/$sample.rawmutcall.gatk.log" >> "08-mutect.commands"
fi
if [ $? -ne 0 ]
then
	echo Mutect failed. Check log file
	exit 8
fi

# STEP 8.5 - Learn read orientation

if [ ! -f ./08.5-LearnBias/$sample.model.tar.gz ]; then
echo "./req-files/gatk/gatk LearnReadOrientationModel -I ./08-Mutect/$sample.f1r2.tar.gz -O ./08.5-LearnBias/$sample.model.tar.gz 1>&2 2>./08.5-LearnBias/$sample.learnbias.gatk.log" >> "08.5-LearnBias.commands"
fi


# STEP 9 - CREATE PILEUP SUMMARIES
known_var=./req-files/common_var/00-common_all.vcf
if [ ! -f ./09-PileupSummary/$sample.pileup.table ]; then
echo "./req-files/gatk/gatk GetPileupSummaries -I ./07-ApplyBaseRecalibration/$sample.recalibrated.bam -V ${known_var} -L ${known_var} -O ./09-PileupSummary/$sample.pileup.table 1>&2 2>./09-PileupSummary/$sample.pileup.gatk.log" >> "09-pileup.commands"
fi
if [ $? -ne 0 ]
then
	echo Failed to create pileup summaries. Check log file.
	exit 8
fi

# STEP 10 - CALCULATE CONTAMINATION
if [ ! -f ./10-CalculateContamination/$sample.contamination.table ]; then
echo "./req-files/gatk/gatk CalculateContamination -I ./09-PileupSummary/$sample.pileup.table -O ./10-CalculateContamination/$sample.contamination.table 1>&2 2>./10-CalculateContamination/$sample.contamination.gatk.log" >> "10-calccontam.commands"
fi
if [ $? -ne 0 ]
then
	echo Failed to calculate contamination. Check log file.
	exit 8
fi

# STEP 11 - FILTER MUTECT CALLS
if [ ! -f ./11-FilterMutectCalls/$sample.filterdvar.vcf ]; then
echo "./req-files/gatk/gatk FilterMutectCalls -R $ref -V ./08-Mutect/$sample.rawmutcall.vcf --ob-priors ./08.5-LearnBias/$sample.model.tar.gz -O ./11-FilterMutectCalls/$sample.filterdvar.vcf 1>&2 2>./11-FilterMutectCalls/$sample.filter.gatk.log" >> "11-filtermutect.commands"
fi
if [ $? -ne 0 ]
then
	echo Failed to filter mutect calls. Check log file.
	exit 8
fi

#old command
#echo "./req-files/gatk/gatk FilterMutectCalls -R $ref -V ./08-Mutect/$sample.rawmutcall.vcf.gz --contamination-table ./10-CalculateContamination/$sample.contamination.table -O ./11-FilterMutectCalls/$sample.filterdvar.vcf.gz 1>&2 2>./11-FilterMutectCalls/$sample.filter.gatk.log" >> "11-filtermutect.commands"

# STEP 13 (want it to match up) - FUNCOTATOR
if [ ! -f ./13-Funcotator/$sample.funcotated.maf ]; then
echo "./req-files/gatk/gatk Funcotator --variant ./11-FilterMutectCalls/$sample.filterdvar.vcf --reference $ref --ref-version hg38 --data-sources-path ./req-files/funcotator_dataSources.v1.6.20190124s --output ./13-Funcotator/$sample.funcotated.maf --output-file-format MAF --annotation-default tumor_barcode:$sample 1>&2 2>./13-Funcotator/$sample.funcotator.gatk.log" >> "13-funcotator.commands"
fi
if [ $? -ne 0 ]
then
	echo "Failed to funcotate (I don't know if that's a word). Check log file."
	exit 8
fi


exit 0
