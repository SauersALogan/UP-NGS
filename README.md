# A unified pipeline for next generation sequencing (UP-NGS)
A developmental pipeline for integrated analysis of next generational metagenomic and metatranscriptomic sequencing. The pipeline is based upon the modular structure of the metaWRAP pipeline (https://github.com/bxlab/metaWRAP/blob/master/README.md and https://doi.org/10.1186/s40168-018-0541-1) while integrating new approaches to analyzing metagenomic and metatranscriptomic sequencing. The pipeline can be used to analyze paired metagenomic and metatranscriptomic sequencing from microbiome samples, or individual metagenomic/metatranscriptomic sequencing from these samples. **This is a developmental version**

# Setup
The UP-NGS pipeline requires the following packages to successfully impliment the code:
  FastQC, Bowtie2,  Trimmomatic, wget, samtools

The suggested method for running these scripts is to setup a conda environment for the UP-NGS pipeline. 
  conda env create -n UP-NGS

Then have conda install the required dependencies
  conda install trimmomatic wget bowtie2 fastqc samtools

To setup the scripts simple download the repository into any directory (although I suggest one which is clearly labelled and stored in a permenant location) and then run the following command to activate the setup script:
  bash <path/to/UP-NGS/folder>/setup_script.sh

This will setup the aliases for each of the modules within the UP-NGS pipeline. The UP-NGS pipeline also utilizes several databases, to aid in convinent setup of these databases a database_setup script has been included. Before starting any analysis it is recommended that you run the UP-NGS_database_setup script.
