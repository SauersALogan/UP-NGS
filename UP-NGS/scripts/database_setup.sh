########################################################################################
# This is a script associated with the paired transcriptome/metagenome pipeline 
# developed by Logan Sauers. The main goal of this script is to download and setup 
# the databases required for the pipeline to run to completion.
#########################################################################################!/bin/bash 

# Strict settings 
set -euo pipefail 

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

# Default settings 
OUTDIR="mouse_genome" 
index_name="mouse_bowtie2_index" 
threads=4 

# Define feaults and URLs, for the mouse genome
NCBI_url="https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF" 
NCBI_sub_folders="000/001/635"
host_accession="GCF_000001635.27_GRCm39" 
genome_fasta="${host_accession}_genomic.fna.gz" 
genome_url="$NCBI_url/$NCBI_sub_folders/$host_accession/$genome_fasta"

# Read arguments
parsed_options=$(getopt -o ho: --long help,outdir:,index_name:,NCBI_url:,NCBI_sub_folders:,host_accession:,threads: -n "$0" --  "$@")

# Check arguments
if [ $? -ne 0 ]; then
	echo ""
    echo "Bad arguments, check inputs as one is likely missing"; 
    echo ""
    help_message
    exit 1
fi

# Needed when using getopt
eval set -- "$parsed_options"

# Go through the options one at a time, using shift to discard the first argument so $2
# becomes $1 again.
while true;  do
    case "$1" in
        --help)
            help_message
            exit 0;;
        --outdir)
            outdir="$2"
            shift 2;;
        --index_name)
            index_name="$2"
            shift 2;;
        --NCBI_url)
            NCBI_url="$2"
            shift 2;;
        --NCBI_sub_folders)
	        NCBI_sub_folders="$2"
		    shift 2;;
        --host_accession)
            host_accession="$2"
            shift 2;;
        --threads)
	        threads="$2"
		    shift 2;;
        --)
            shift
            break;;
        *)
            echo "Unknown option: $1"
            help_message
            exit 1;;
    esac
done

# Initial Reporting
# Check if parameters entered
if [ -z "${outdir:-}" ] || [ -z "$index_name" ] || [ -z "$NCBI_url" ] || [ -z "$NCBI_sub_folders" ] || [ -z "$host_accession" ]; then 
	echo "Error: Missing mandatory arguments." 
	help_message 
	exit 1 
fi

# Update genome URL 
genome_fasta="${host_accession}_genomic.fna.gz" 
genome_url="$NCBI_url/$NCBI_sub_folders/$host_accession/$genome_fasta"

# Check is the directory for databases exists
if [ ! -d "$outdir" ]; then
	echo ""
	echo "Your databases directory does not exist, creating it now and beginning download"
	mkdir $outdir
	echo ""
fi

# Check is the host genome subdirectory exists
if [ ! -d "$outdir/host_genome" ]; then
	echo ""
	echo "Your host genome subfolder does not exist, creating it now and beginning download"
	mkdir $outdir/host_genome
	echo ""
fi

# Check if the host genome is already downloaded
if [ ! "$(ls -A "$outdir/host_genome")" ]; then
	echo ""
	echo "Your host genome directory already exists, but it is empty, beginning download"
# Download the genome 
	echo "Downloading NCBI mouse genome..." 
	wget -P "$outdir/host_genome" "$genome_url" 

else
	echo ""
	echo "There is a file in the host genome subfolder, it seems you've already downloaded the host genome so I will skip this. If you have not, ensure the folder is empty and retry."
fi 

# Check is the index subdirectory exists
if [ ! -d "$outdir/host_index" ]; then
	echo ""
	echo "Your bowtie index directory does not exist, creating it now"
	mkdir $outdir/host_index
	echo ""
fi

# Check if the genome is already uncompressed
if [ ! -f "$outdir/host_genome/${genome_fasta%.gz}" ]; then 
	echo "Uncompressing the genome..." 
	gunzip -c "$outdir/host_genome/$genome_fasta" > "$outdir/host_genome/${genome_fasta%.gz}" 
else 
	echo "Genome already uncompressed. Skipping uncompression." 
fi

# Check if genome FASTA file was successfully extracted 
if [ ! -s "$outdir/host_genome/${genome_fasta%.gz}" ]; then 
	echo "Failed to extract genome FASTA file." 
exit 1 
fi 

# Generate Bowtie2 index if not already created 
if [ ! "$(ls -A "$outdir/host_index")" ]; then
	echo "Generating Bowtie2 index..." 
	bowtie2-build --threads "$threads" "$outdir/host_genome/${genome_fasta%.gz}" "$outdir/host_index/$index_name" 
	echo "Bowtie2 index created successfully in $outdir/host_index."
else
	echo "It appears there is already files in your index folder. If you already created the index great! Either way I dislike overwriting files so I will skip making the index."
	echo ""
fi
