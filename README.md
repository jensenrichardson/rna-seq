# RNA-Seq

This repository requires the use of `git-lfs` in order to use the test data contained in `test-fastq`. You can find instruction for installing it [here](https://git-lfs.github.com/).

This is going to be a pipeline designed to call RNA-seq mutation by first mapping with STAR, and then calling according to the GATK best practices pipeline.

Notes:
* You should have a star index called `star-ref` and put fastq files in a directory called `fastq`.
* Git will ignore any files beginning with two numbers. All analysis folders will begin with two numbers. I recommend that you name slurm files with two numbers at the beginning like `02-mapping.star.slurm` to ensure that they aren't caught up by git.
