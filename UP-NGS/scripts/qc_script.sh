########################################################################################
# This is a qc package associated with the paired transcriptome/metagenome pipeline 
# developed by Logan Sauers. The main goal of this script is to assess the initial 
# quality of the reads, trim bad reads and sequences, and remove contaminating host 
# DNA/RNA. 
########################################################################################
# Strict Bash settings
set -euo pipefail

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

input_error_message(){
	echo ""
	echo "There was an error with the input RNA and DNA sequences"
	echo "It is likely that you mispelled the input files"
	echo "Please double check the input file directories, names, and extensions."
	echo ""
}

# Default paramaters
threads=1; outdir="false"; DNA1="false"; DNA2="false"; RNA1="false"; RNA2="false"; genome_index="false"

# Trimming parameters
THREADS=$threads
MINLEN=36
LEADING=3
TRAILING=3
SLIDINGWINDOW="4:20"

# Read arguments
parsed_options=$(getopt -o ho: --long help,outdir:,DNA1:,DNA2:,RNA1:,RNA2:,threads:,genome_index: -n "$0" --  "$@")

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
        --DNA1)
            DNA1="$2"
            shift 2;;
        --DNA2)
            DNA2="$2"
            shift 2;;
        --RNA1)
            RNA1="$2"
            shift 2;;
        --RNA2)
            RNA2="$2"
            shift 2;;
        --threads)
	        threads="$2"
		    shift 2;;
		--genome_index)
			genome_index="$2"
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
missing_args=()
if [ "$outdir" = "false" ]; then missing_args+=("outdir"); fi
if [ "$DNA1" = "false" ]; then missing_args+=("DNA1"); fi
if [ "$DNA2" = "false" ]; then missing_args+=("DNA2"); fi 
if [ "$RNA1" = "false" ]; then missing_args+=("RNA1"); fi 
if [ "$RNA2" = "false" ]; then missing_args+=("RNA2"); fi
if [ "$genome_index" = "false" ]; then missing_args+=("database"); fi

if [ "${#missing_args[@]}" -gt 0 ]; then
	echo ""
	echo "Error: Missing mandatory arguments: ${missing_args[*]}"
	echo ""
	help_message
	exit 1
fi

if [ "$DNA1" = "$DNA2" ] || [ "$DNA1" = "$RNA1" ] || [ "$DNA1" = "$RNA2" ] || [ "$DNA2" = "$RNA1" ] || [ "$DNA2" = "$RNA2" ] || [ "$RNA1" = "$RNA2" ]; then 
	echo ""
	echo "Some of your input reads share the same name, please check your input values";
	echo ""
	exit 1
fi

if [ ! -s $DNA1 ]; then echo ""; echo "error $DNA1 file is incorrect"; exit 1; fi
if [ ! -s $DNA2 ]; then echo ""; echo "error $DNA2 file is incorrect"; exit 1; fi
if [ ! -s $RNA1 ]; then echo ""; echo "error $RNA1 file is incorrect"; exit 1; fi
if [ ! -s $RNA2 ]; then echo ""; echo "error $RNA2 file is incorrect"; exit 1; fi

if [ ! -d "$outdir" ]; then
	echo ""
    echo "Your QC Output directory does not exist, creating it now and moving to fastqc"; 
	mkdir -p $outdir; 
else
	echo ""
    echo "Your QC Output directory already exists, I will only proceed through tasks for which subfolders are empty"; 
	echo ""    
fi

echo ""
echo " Starting fastqc on raw reads"
date
echo ""

# Creating preliminary fastqc subfolder 
if [ ! -d "$outdir/initial_quality" ]; then
	echo ""
    echo "Subfolder for initial fastqc does not exist, creating it now"; 
	mkdir -p $outdir/initial_quality; 
    echo ""; 
fi

if [ ! "$(ls -A "$outdir/initial_quality")" ]; then
	echo ""
	echo "The initial quality folder exists but is empty, I will proceed"

# Run FastQC
fastqc -t $threads -o "$outdir"/initial_quality -f fastq $DNA1 $DNA2 $RNA1 $RNA2

#Fail check
if [ $? -ne 0 ]; then
	echo ""
	echo "Initial fastqc failed, exiting. Check error logs for additional information";
	echo ""
	exit 1;
else
	echo ""
	echo "Initial fastqc successful, proceeding to trimming"
	echo ""
fi

else
	echo ""
    echo "Subfolder for initial fastqc exists and is not empty, I dislike overwriting directories with files, I will skip initial quality checking"; 
    echo "" 
fi

# Creating preliminary trimming subfolder 
if [ ! -d "$outdir/trimmed_reads" ]; then
	echo ""
    echo "Subfolder for trimmed reads does not exist, creating it now"
    mkdir $outdir/trimmed_reads 
    echo ""
fi

if [ ! "$(ls -A "$outdir/trimmed_reads")" ]; then
	echo ""
	echo "Sub folder for trimming exists but is empty, I will proceed"

# Trimming file names and ensuring they write to the new subfolder
echo ""
echo "Trimming DNA file names and ensuring they write to the new subfolder"
echo ""
DNA1_trimmed="$outdir/trimmed_reads/$(basename "${DNA1%.fq}_trimmed.fastq")"
DNA1_unpaired="$outdir/trimmed_reads/$(basename "${DNA1%.fq}_unpaired.fastq")"
DNA2_trimmed="$outdir/trimmed_reads/$(basename "${DNA2%.fq}_trimmed.fastq")"
DNA2_unpaired="$outdir/trimmed_reads/$(basename "${DNA2%.fq}_unpaired.fastq")"

# Verifying inputs
echo ""
echo "Input files: $DNA1, $DNA2"
echo "Output files: $DNA1_trimmed, $DNA1_unpaired, $DNA2_trimmed, $DNA2_unpaired"
echo ""

# Running trimmomatic on DNA reads
trimmomatic PE -threads $threads -phred33 "$DNA1" "$DNA2" "$DNA1_trimmed" "$DNA1_unpaired" "$DNA2_trimmed" "$DNA2_unpaired" LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:36

#Fail check
if [ $? -eq 0 ]; then
	echo ""
	echo "Trimming DNA reads successful, moving to RNA reads"
	echo ""
else
	echo ""
	echo "Trimming DNA reads failed, exiting. Check error logs for additional information "
	exit 1
fi

# Trimming file names and ensuring they write to the new subfolder
echo ""
echo "Trimming RNA file names and ensuring they write to the new subfolder"
echo ""
RNA1_trimmed="$outdir/trimmed_reads/$(basename "${RNA1%.fq}_trimmed.fastq")"
RNA1_unpaired="$outdir/trimmed_reads/$(basename "${RNA1%.fq}_unpaired.fastq")"
RNA2_trimmed="$outdir/trimmed_reads/$(basename "${RNA2%.fq}_trimmed.fastq")"
RNA2_unpaired="$outdir/trimmed_reads/$(basename "${RNA2%.fq}_unpaired.fastq")"

# Verifying inputs
echo ""
echo "Input files: $RNA1, $RNA2"
echo "Output files: $RNA1_trimmed, $RNA1_unpaired, $RNA2_trimmed, $RNA2_unpaired"
echo ""

# Running trimmomatic on RNA reads
trimmomatic PE -threads $threads -phred33 "$RNA1" "$RNA2" "$RNA1_trimmed" "$RNA1_unpaired" "$RNA2_trimmed" "$RNA2_unpaired" LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:36

#Fail check
if [ $? -eq 0 ]; then
	echo ""
	echo "Trimming RNA reads successful, moving to host removal"
	echo ""
else
	echo ""
	echo "Trimming RNA reads failed, exiting. Check error logs for additional information "
	exit 1
fi

else
	echo ""
    echo "Subfolder for trimmed reads exists, I dislike overwriting directories with files, so I will skip trimming"
fi

# Creating host removed DNA subfolder 
if [ ! -d "$outdir/host_removed/DNA_reads" ]; then
	echo ""
    echo "Subfolder for host removed DNA reads does not exist, creating it now"; 
	mkdir -p $outdir/host_removed/DNA_reads; 
    echo ""; 
fi

if [ ! "$(ls -A "$outdir/host_removed/DNA_reads")" ]; then
	echo ""
	echo "The host removed folder for DNA reads exists but is empty, I will proceed"

# Ensure the DNA variables are assigned from trimming
DNA1_trimmed="$outdir/trimmed_reads/$(basename "${DNA1%.fq}_trimmed.fastq")"
DNA2_trimmed="$outdir/trimmed_reads/$(basename "${DNA2%.fq}_trimmed.fastq")"

if [ ! -f $DNA1_trimmed ]; then echo ""; echo "error $DNA1_trimmed file does not exist"; exit 1; fi
if [ ! -f $DNA2_trimmed ]; then echo ""; echo "error $DNA2_trimmed file does not exist"; exit 1; fi

# Verifying inputs
echo ""
echo "Input files: $DNA1_trimmed, $DNA2_trimmed"
echo "Output files: "
echo ""

# Filtering out host reads from DNA reads
bowtie2 -x $genome_index -1 $DNA1_trimmed -2 $DNA2_trimmed --threads $threads --very-sensitive-local --un-conc $outdir/host_removed/DNA_reads --quiet

else
	echo ""
    echo "Subfolder for host removed DNA exists, I dislike overwriting directories with files, so I will skip final QC check"
fi

# Creating host removed RNA subfolder 
if [ ! -d "$outdir/host_removed/RNA_reads" ]; then
	echo ""
    echo "Subfolder for host removed RNA reads does not exist, creating it now"; 
	mkdir -p $outdir/host_removed/RNA_reads; 
    echo ""; 
fi

if [ ! "$(ls -A "$outdir/host_removed/RNA_reads")" ]; then
	echo ""
	echo "The host removed folder for RNA reads exists but is empty, I will proceed"

# Ensure the RNA variables are assigned from trimming
RNA1_trimmed="$outdir/trimmed_reads/$(basename "${RNA1%.fq}_trimmed.fastq")"
RNA2_trimmed="$outdir/trimmed_reads/$(basename "${RNA2%.fq}_trimmed.fastq")"

if [ ! -f $RNA1_trimmed ]; then echo ""; echo "error $RNA1_trimmed file does not exist"; exit 1; fi
if [ ! -f $RNA2_trimmed ]; then echo ""; echo "error $RNA2_trimmed file does not exist"; exit 1; fi

# Verifying inputs
echo ""
echo "Input files: $RNA1_trimmed, $RNA2_trimmed"
echo "Output files: "
echo ""

# Filtering out host reads from DNA reads
bowtie2 -x $genome_index -1 $RNA1_trimmed -2 $RNA2_trimmed --threads $threads --very-sensitive-local --un-conc $outdir/host_removed/RNA_reads --quiet

else
	echo ""
    echo "Subfolder for host removed RNA exists, I dislike overwriting directories with files, so I will skip final QC check"
fi

echo ""
echo " Starting fastqc on raw reads"
date
echo ""

# Creating preliminary fastqc subfolder 
if [ ! -d "$outdir/final_quality" ]; then
	echo ""
    echo "Subfolder for fastqc on final reads does not exist, creating it now"; 
	mkdir -p $outdir/final_quality; 
    echo ""; 
fi

if [ ! "$(ls -A "$outdir/final_quality")" ]; then
	echo ""
	echo "The final quality folder exists but is empty, I will proceed"

# Reassign the final reads
RNA1_final="$outdir/host_removed/RNA_reads/un-conc-mate.1"
RNA2_final="$outdir/host_removed/RNA_reads/un-conc-mate.2"
DNA1_final="$outdir/host_removed/DNA_reads/un-conc-mate.1"
DNA2_final="$outdir/host_removed/DNA_reads/un-conc-mate.2"

# Moving final reads to new folder and renaming
if [ ! -d "$outdir/final_reads" ]; then
	echo ""
    echo "Subfolder for final reads does not exist, creating it now"; 
	mkdir -p $outdir/final_reads; 
    echo ""; 
fi

if [ ! "$(ls -A "$outdir/final_reads")" ]; then
	echo ""
	echo "The final reads folder exists but is empty, I will proceed"

# verify files exist
if [ -f $DNA1_final ] && [ -f $DNA2_final ] && [ -f $RNA1_final ] && [ -f $RNA2_final ]; then
mv "$DNA1_final" "$outdir/final_reads/$(basename "${DNA1%.fq}_final.fastq")"
mv "$DNA2_final" "$outdir/final_reads/$(basename "${DNA2%.fq}_final.fastq")"
mv "$RNA1_final" "$outdir/final_reads/$(basename "${RNA1%.fq}_final.fastq")"
mv "$RNA2_final" "$outdir/final_reads/$(basename "${RNA2%.fq}_final.fastq")"
else
	echo "Error: One or more of the final read files are missing. Please check the previous outputs to determine where the error is occuring."
fi

else
	echo ""
    echo "Subfolder for final reads exists, I dislike overwriting directories with files, so I will skip final QC check"
fi

# Run FastQC
fastqc -t $threads -o "$outdir/final_quality" -f fastq "$outdir/final_reads/$(basename "${DNA1%.fq}_final.fastq")" "$outdir/final_reads/$(basename "${DNA1%.fq}_final.fastq")" "$outdir/final_reads/$(basename "${DNA1%.fq}_final.fastq")" "$outdir/final_reads/$(basename "${DNA1%.fq}_final.fastq")"

#Fail check
if [ $? -ne 0 ]; then
	echo ""
	echo "Final fastqc failed, exiting. Check error logs for additional information";
	echo ""
	exit 1;
else
	echo ""
	echo "Final fastqc successful, proceeding to trimming"
	echo ""
fi

else
	echo ""
    echo "Subfolder for final fastqc exists and is not empty, I dislike overwriting directories with files, I will skip initial quality checking"; 
    echo "" 
fi

# Final reporting
echo ""
echo "Listing the output files: "
ls -lh "$outdir"
ls -lh "$outdir/final_quality"
ls -lh "$outdir/final_reads"

echo ""
echo "Done with script"
date
