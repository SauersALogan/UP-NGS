# A unified pipeline for next generation sequencing (UP-NGS)
A developmental pipeline by Logan Sauers and the Coyte Lab for integrated analysis of next generational metagenomic and metatranscriptomic sequencing. The pipeline is based upon the modular structure of the metaWRAP pipeline (https://github.com/bxlab/metaWRAP/blob/master/README.md and https://doi.org/10.1186/s40168-018-0541-1) while integrating new approaches to analyzing metagenomic and metatranscriptomic sequencing. The pipeline can be used to analyze paired metagenomic and metatranscriptomic sequencing from microbiome samples, or individual metagenomic/metatranscriptomic sequencing from these samples.

The pipeline also integrates some of the ideas and procedures developed in metaGT (https://github.com/ablab/metaGT and https://doi.org/10.3389/fmicb.2022.981458) to construct expression tables. With additional functionality aimed at determining the gene expression of each bacterial population/absolute population size.

**This is a developmental version and I do not claim ownership over any of the tools utilized by this pipeline/wrapper. When citing please also cite the individual pieces of software, listed in the setup, individually**

# Setup
The UP-NGS pipeline requires the following packages to successfully impliment the code:
  FastQC, Bowtie2,  Trimmomatic, wget, samtools

The suggested method for running these scripts is to setup a conda environment for the UP-NGS pipeline. 
 ```
  conda env create -n UP-NGS
```

Then have conda install the required dependencies
```
  conda install trimmomatic wget bowtie2 fastqc samtools
```

To setup the scripts simple download the repository into any directory (although I suggest one which is clearly labelled and stored in a permenant location) and then run the following command to activate the setup script:
```
  bash <path/to/UP-NGS/folder>/setup_script.sh --UPNGS_basefolder = <path/to/UP-NGS/folder>
```

This will setup the aliases for each of the modules within the UP-NGS pipeline. The UP-NGS pipeline also utilizes several databases, to aid in convinent setup of these databases a database_setup script has been included. Before starting any analysis it is recommended that you run the UP-NGS_database_setup script.

# Current developmental goals
**Overall pipeline**

Testing data and tutorial:
 - Write tutorial - *Under developement*
 - Determine testing dataset - **Completed**
 - Determine simulation dataset - *Under developement*
 - Determine method for end-user to obtain testing/simulation data - *Under developement*
 - Include both in downloads folder 
 - Integrate into tutorial

Readme:
  - Introduction - *Under developement*
  - Setup - *Under developement*
  - Module descriptions
 -  Benchmarking 

Setup_script:
  - Alias setup - **Completed**
  - Allow overwrite of previous alias/UP-NGS setup - **Completed**
  - Allow users to define folder path with the setup - *Under developement*
  - Beta testing
  - Deployment 

Database_setup:
  - Bowtie2 database download and indexing - **Completed**
  
Read_qc:
 - Initial Fastqc - **Completed**
 -  Trimmomatic integration - **Completed**
 - Host removal integration - **Completed**
 - Final fastqc - **Completed**
 -  Script to properly move and rename final fastq files - **Completed**
 - Ensure proper parallelization - **Completed**
 - Integrate RNA only/DNA only modes - *Under developement*
 - Beta testing  
 - Deployment

Assembly:
 - Metagenomic assembly with metaspades - *Under developement*
 - Transcriptomic assembly with rnaspades - *Under developement*
 - Ensure proper parallelization
 - Integrate RNA only/DNA only modes
 - Beta testing
 - Deployment

**Metagenome pipeline**

Binning:
 - Determine which binners to include - *Under developement*
 - Beta testing
 - Deployment
  
Bin refinement:
 - Integrate CheckM
 - Develop scoring for completeness, contamination, and contig number + size
 - Beta testing
 - Deployment
  
Dereplication and Classification:
 - Integrate dRep2 bin dereplication across all input samples
 - Beta testing
 - Deployment
  
Quantification
 - Determine best method for bin quantification
 - Beta testing
 - Deployment

**Transcriptomic pipeline**

Alignment to metagenomes:
 - Annotation of metagenomic bins 
 - Alignment to metagenoms with minimap2
 - Transcript correction

Quantification
 - Relative expression quantification
 - Expression/population size quantification

# Contributions and acknowledgements

**Author** - Logan A Sauers

**Principal Investigator** - Katharine Coyte

**Pipeline testers** 
