# A tutorial for setting up the databases required for UP-NGS

**Introduction**

UP-NGS utilizes several varying databases in order to fully finish its functionality. These include a bowtie2 index made from the genome of the specific host, GTDK database for classifying the metagenomic bins, the KEGG databse for annotating genes, etc. This tutorial will add you in utilizing the built in 
"UP-NGS_database_setup" script to automatically download, create, and setup these databases. 

**Host genome index for removing host reads**

This script does the bulk of the database setup and will do so automatically as long as the proper input parameters are included. 

```
help_message () {
	echo ""
	echo "This is the quality control script for [pipeline name] mandatory parameters include"
	echo ""
	echo "Parameters:"
	echo ""
	echo "index_name = <desired name of the bowtie2 index>"
	echo "NCBI_url = <NCBI download url, this shouldn't change unless NCBI changes, this does happen from time to time so I am including this as a variable just incase>"
	echo "NCBI_sub_folders= <The subfolders the accession are located in, usually three strings of numbers such as 000/001/635>"
	echo "host_accession = <the host accession number for download, check the ftp through browser as you will need to include all the subdirectories after the GCF subfolder>"
	echo "outdir = <output directory>"
	echo "threads = <number of threads>"
	echo ""
}
```

An example of this script follows, if you use this example it will download the Mus musculus genome and setup a bowtie2 index for it in the "database" directory:

```
UPNGS_database_setup --outdir=database 
```
