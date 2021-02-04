#!/bin/bash

# make directories
./makedir.sh

# location of fastq files
flocation=$1

# gets an iterable list of the sample names with no duplicates
flist=$(ls $flocation)
names=
newline="\n"
for fastq in $flist
do
	name=$(basename $fastq | grep -Po '^.+?(?=_L00)') 
	names="$names$newline$name"
done
names=$(echo -e $names | sort | uniq)

# maps each lane individually, then adds read group information and then merges the bam file
for name in $names
do
	sampleloc=$(ls $flocation/$name*)
	#I would have wanted to send name as an argument, but because merge iterates through them, it would be too difficult to look for. It's far easier and more reliable to set it as an env variable in this case.
	export name=$name
	./mergefastq.sh $sampleloc
done

if [ $? -ne 0 ]
then
	echo merging fastq files failed.
	exit 1
fi

for name in $names
do
	./preprocessbam.sh ./04.5-mergedlanes/$name.merged.bam $name
done

if [ $? -ne 0 ]
then
	echo Something went wrong during the processing of the bam.
	exit 1
else
	echo Fastq to bam and preprocessing complete.
fi

for commandfile in *.commands
do
	mv "$commandfile" "${commandfile//.commands/.commands.tmp}"
	sort $commandfile.tmp | uniq > $commandfile
	rm $commandfile.tmp
done
