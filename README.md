# RNA-Seq

This repository requires the use of `git-lfs` in order to use the test data contained in `test-fastq`. You can find instruction for installing it [here](https://git-lfs.github.com/).

This is going to be a pipeline designed to call RNA-seq mutation by first mapping with STAR, and then calling according to the GATK best practices pipeline.

Note that you should also have a star index called `star-ref` and put fastq files in a directory called `fastq`.
