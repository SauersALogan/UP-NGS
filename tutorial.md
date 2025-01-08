# Introduction

This is a tutorial for the UP-NGS pipeline which was developed for the analysis of metagenomic and metatranscriptomic sequencing. This tutorial assumes you have **already followed the steps in the readme** to setup the aliases for the pipeline and **followed the information in the database setup** tutorial. 
If you have not please exist and see both the readme and database setup tutorial.

# Test and simulation data
Download the testing and simulation data as follows

```
wget <file path>
```

# UP-NGS_read_qc

This module is focused on quality control and assessment of the read quality for your input data. It utilizes fastqc to assess the initial and final quality of the DNA reads, trimmomatic to remove any remaining adaptors and poor bases, and then bowtie2 to remove any contaminating host DNA. 
In order to run this module follow the required inputs from the help_message

```
UP-NGS --help

help_message () {
	echo ""
	echo "This is the quality control script for [pipeline name] mandatory parameters include"
	echo ""
	echo "Parameters:"
	echo ""
	echo "DNA1      = <forward DNA reads>"
	echo "DNA2      = <reverse DNA reads>"
	echo "RNA1      = <forward RNA reads>"
	echo "RNA2      = <reverse RNA reads>"
	echo "outdir    = <output directory>"
	echo "genome_index  = <exact path to index created in TRANS_database_setup>"
	echo ""
}
```

An example of what is expected for the input of this module can be found below, this will run the quality control module on tutorial data, outputting the results to the "tutorial_qc" folder. **This folder contains metagenomic and metatranscriptomic read files with 2,000,000 reads each from mice samples**.
The code below utilizes the mouse genome to remove host reads, so please follow the **in the database setup tutorial**.

```
UP-NGS_read_qc --genome_index databases/host_index/mouse_bowtie2_index --DNA1=UP-NGS/tutorial_data/DNA_1.fq --DNA2=UP-NGS/tutorial_data/DNA_2.fq --RNA1=UP-NGS/tutorial_data/RNA_1.fq --RNA2=UP-NGS/tutorial_data/RNA_2.fq --outdir=tutorial_qc
```
