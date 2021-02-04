#/bin/bash

# note that name was exported by callSomaticScript

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

if [ ! -d './star-ref/' ]; then
	echo "Reference not found. Make sure that it is named \"star-ref\" and in this directory"
	exit 1
fi
starGenome="./star-ref"

listOfFiles=
readgroups=
s1r1=
s1r2=
s2r1=
s2r2=
for lane in $lanes
do
	# note that name was exported by callSomaticScript
	reads=$(ls $dir/${name}_${lane}*)
	set -- $reads
	if [ -z "$s1r1" ]; then
		s1r1=$1
		s1r2=$2
	elif [ -z "$s2r1" ]; then
		s2r1=$1
		s2r2=$2
	fi
	if [ -z "${readgroups}" ]; then
		readgroups="ID: rg.${name}_${lane}"
	else
		readgroups="${readgroups} , ID: rg.${name}_${lane}"
	fi
done
listOfFiles="${s1r1},${s2r1} ${s1r2},${s2r2}"

echo -e "STAR \
	--runThreadN 20 \
	--genomeDir ${starGenome} \
	--readFilesIn ${listOfFiles} \
	--outSAMattrRGline ${readgroups} \
	--outSAMtype BAM Unsorted \
	--twopassMode Basic \
	--outFileNamePrefix ./02-mapping/${name}"

exit 0 
set -- $lanes
sample=$name

if [ ! -f ./05-markduplicates/$sample.markdup.bam ]; then
echo "./req-files/gatk/gatk MarkDuplicatesSpark -I ./04.5-sortedlanes/${sample}_$1.sorted.bam -I ./04.5-sortedlanes/${sample}_$2.sorted.bam -M ./05-markduplicates/$sample.markdup.metrics.txt -O ./05-markduplicates/$sample.markdup.bam 1>&2 2>./05-markduplicates/$sample.markdup.gatk.log" >> "05-markdup.commands"
fi

unset lanes
