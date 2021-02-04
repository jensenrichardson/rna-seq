#/bin/bash

# this takes any number of fastq files FROM THE SAME SAMPLE, with different lanes. Maps the lanes together
# and then merges the output after doing read group addition with FastqToSam and MergeBam.
# this gets everything but the lane from the sample.
# note that the master script, call somtic mutants, sets an env variable called name which gives the name of the smaple

dir=$(dirname "$1")

# this gets a list of the lanes
lanes=
newline='\n'
for fastq in $@
do
	lane=$(basename $fastq | grep -oh 'L00.')
	lanes=$lanes$newline$lane
done
lanes=$(echo -e $lanes | sort | uniq)

for lane in $lanes
do
	# set the reads as $1 and $2
	reads=$(ls $dir/${name}_$lane*)
	set -- $reads
	#echo $1
	#echo $2
	#echo -e '\n'

	ref=./req-files/refGenome/GRCh38.p7.genome.fa

	# ensure that we have the reference
	if [ -f $ref ]; then
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

	# import the two paired end fastq files
	fastq1=$1
	fastq2=$2

	# get the name of the sample to be used in all the stuff after.
	sample=$name
	sample=${sample}_$lane

	# STEP 2 - MAPPING (really step 1, but I want everything to line up with what's in my own directory)
	bwathread=4

	# makes sure that the mapping didn't already happen. if the mapped file doesn't exist, then map
	if [ ! -f ./02-mapping/$sample.mapped.sam ]; then
	echo "bwa mem -t $bwathread -o ./02-mapping/$sample.mapped.sam $ref $fastq1 $fastq2 1>&2 2>./02-mapping/$sample.mapping.bwa.log" >> "02-mapping.commands"
	fi

	if [ $? -ne 0 ]
	then
		echo Mapping failed! Check the log file!
		exit 2
	fi


	# STEP 3 - FastqToSam - convert the fastq to an unmapped bam (add read names, etc)
	readgroup=rg.$sample

	if [ ! -f ./03-bamconversion/$sample.unmapped.bam ]; then	
	echo "./req-files/gatk/gatk FastqToSam -F1 $fastq1 -F2 $fastq2 -O ./03-bamconversion/$sample.unmapped.bam --SAMPLE_NAME $sample --READ_GROUP_NAME $readgroup --PLATFORM ILLUMINA 1>&2 2>./03-bamconversion/$sample.bamconvert.gatk.log" >> "03-bamconversion.commands"
	fi

	if [ $? -ne 0 ]
	then
		echo Bam conversion failed! Check the log file!
		exit 3
	fi

	# STEP 3.5 - Sort unmapped bam by queryname

	if [ ! -f ./03.5-sortubam/$sample.sorted.unmapped.bam ]; then
	echo "./req-files/gatk/gatk SortSam -I ./03-bamconversion/$sample.unmapped.bam -O ./03.5-sortubam/$sample.sorted.unmapped.bam -SORT_ORDER queryname 1>&2 2>./03.5-sortubam/$sample.sortubam.gatk.log" >> "03.5-sortubam.commands"
	fi

	# STEP 4 - Merge Bam and sam files

	if [ ! -f ./04-mergebam/$sample.bamsammerged.bam ]; then
	echo "./req-files/gatk/gatk MergeBamAlignment -O ./04-mergebam/$sample.bamsammerged.bam -R $ref -UNMAPPED ./03.5-sortubam/$sample.sorted.unmapped.bam -ALIGNED ./02-mapping/$sample.mapped.sam 1>&2 2>./04-mergebam/$sample.merge.gatk.log" >> "04-bamsammerge.commands"
	fi

	if [ $? -ne 0 ]
	then
		echo Bam and sam merge failed! Check the log file!
		exit 4
	fi
	
	if [ ! -f ./04.5-sortedlanes/$sample.sorted.bam ]; then	
	echo "./req-files/gatk/gatk SortSam -I ./04-mergebam/$sample.bamsammerged.bam -O ./04.5-sortedlanes/$sample.sorted.bam -SORT_ORDER queryname 1>&2 2>./04.5-sortedlanes/$sample.sort.gatk.log" >> "04.5-sortlanes.commands"
	fi
done


#need to be able to access each lane. Each of these was only done twice, so I'm hard coding it but this should
# probably be changed at some point

set -- $lanes
sample=$name

if [ ! -f ./05-markduplicates/$sample.markdup.bam ]; then
echo "./req-files/gatk/gatk MarkDuplicatesSpark -I ./04.5-sortedlanes/${sample}_$1.sorted.bam -I ./04.5-sortedlanes/${sample}_$2.sorted.bam -M ./05-markduplicates/$sample.markdup.metrics.txt -O ./05-markduplicates/$sample.markdup.bam 1>&2 2>./05-markduplicates/$sample.markdup.gatk.log" >> "05-markdup.commands"
fi

unset lanes
