#!/bin/bash

# Function to display help message
display_help() {
    echo "Usage: $0 -o <output_folder> -G <genome_fasta_file> -gtf <gtf_file> -gff <gff3_file> -fq <folder_containing_fastq_files> -bed <bed_file> -t <number_of_threads> -RAM <ram_to_be_used>"
    echo "Options:"
    echo "  -o/--output=<output_folder>       Output folder (required)"
    echo "  -G/--genome=<genome_fasta_file>   Genome FASTA file (required)"
    echo "  -gtf/--gtf=<gtf_file>               GTF file (required)"
    echo "  -gff/--gff=<gff3_file>               GFF3 file (required)"
    echo "  -fq/--fastq=<fastq_folder>         Folder containing FASTQ files (required)"
    echo "  -bed/--bed=<bed_file>               BED file (required)"
    echo "  -t/--threads=<number_of_threads>  Number of threads to use (required)"
    echo "  -RAM/--ram=<ram_to_be_used>         RAM to be used (required)"
    echo "  -h, --help                     Display this help message"
    echo "  -v, --version                  Display version information"
    echo ""
    echo "Note: If 'bed' file is missing, create it using 'minimap2-master/misc/paftools.js gff2bed XXX.gtf > XXX.bed'"
}


# Function to display version information
display_version() {
    echo "Script version 1.0"
}

# Check if required tools are installed or available locally
check_tools() {
    tools=("fastqc" "flexbar" "samtools" "minimap2" "featureCounts" "stringtie")
    missing_tools=()

    for tool in "${tools[@]}"; do
        if ! dpkg -s "$tool" >/dev/null 2>&1 && ! command -v "$tool" >/dev/null 2>&1; then
            if [ -x "./$tool" ]; then
                echo "Executable '$tool' found locally."
                export PATH="$PATH:$(pwd)"
            else
                missing_tools+=("$tool")
            fi
        fi
    done

    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo "The following tools are missing or not installed:"
        printf '%s\n' "${missing_tools[@]}"
        echo "Please use 'Tools_installation.sh' to install them or specify their executable path."
        exit 1
    fi
}

# Parse command-line options
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -o=*|--output=* )    output_folder="${1#*=}"; shift ;;
        -G=*|--genome=* )    genome_file="${1#*=}"; shift ;;
        -gtf=*|--gtf=* )       gtf_file="${1#*=}"; shift ;;
        -gff=*|--gff=* )       gff_file="${1#*=}"; shift ;;
        -fq=*|--fastq=* )     fastq_folder="${1#*=}"; shift ;;
        -bed=*|--bed=* )       bed_file="${1#*=}"; shift ;;
        -t=*|--threads=* )   threads="${1#*=}"; shift ;;
        -RAM=*|--ram=* )       ram="${1#*=}"; shift ;;
        -o*|--output )      shift; output_folder="$1"; shift ;;
        -G*|--genome )      shift; genome_file="$1"; shift ;;
        -gtf*|--gtf )         shift; gtf_file="$1"; shift ;;
        -gff*|--gff )         shift; gff_file="$1"; shift ;;
        -fq*|--fastq )       shift; fastq_folder="$1"; shift ;;
        -bed*|--bed )         shift; bed_file="$1"; shift ;;
        -t*|--threads )     shift; threads="$1"; shift ;;
        -RAM*|--ram )         shift; ram="$1"; shift ;;
        -h | --help )   display_help; exit 0 ;;
        -v | --version ) display_version; exit 0 ;;
        * )             echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
done

# Check if all required parameters are provided
if [[ -z "$output_folder" || -z "$genome_file" || -z "$gtf_file" || -z "$gff_file" || -z "$fastq_folder" || -z "$bed_file" || -z "$threads" || -z "$ram" ]]; then
    echo "All options (-o, -G, -gtf, -gff, -fq, -bed, -t, -RAM) are mandatory."
    display_help
    exit 1
fi

# Check and handle missing tools
check_tools

# Execution of commands
echo "#########################################"
echo "[Running Alignment]"
echo "#########################################"
StartAlignment=$(date)

ls ${fastq_folder}/*.fastq.gz > fastq_files.txt
mkdir -p ${output_folder}/Alignment ${output_folder}/FeatureCounts ${output_folder}/Stringtie

while IFS= read -r read1; do
    pos1=${read1##*/}
    echo "Running Alignment on ${pos1%.fastq.gz}"
    minimap2 -ax splice --junc-bed ${bed_file} -p 1.0 -N 100 -t ${threads} ${genome_file} $read1 | samtools sort -@ ${ram} -o ${output_folder}/Alignment/${pos1%.fastq.gz}_sort.bam
    samtools index ${output_folder}/Alignment/${pos1%.fastq.gz}_sort.bam

    if [ $? -ne 0 ]; then
        echo "Error in alignment step. Exiting."
        exit 1
    fi
done < fastq_files.txt

EndAlignment=$(date)
echo "Total Alignment time: $EndAlignment - $StartAlignment"

echo "#########################################"
echo "[Starting FeatureCounts]"
echo "#########################################"
date

# Write bam_loctn.txt file with BAM file names for featureCounts
find ${output_folder}/Alignment -name "*_sort.bam" | sed 's#.*/##; s/_sort.bam//' > bam_loctn.txt

cat bam_loctn.txt | parallel -j 4 "featureCounts -o ${output_folder}/FeatureCounts/{}.tsv -a ${gtf_file} -T 4 -L --largestOverlap --primary -G ${genome_file} ${output_folder}/Alignment/{}_sort.bam"

if [ $? -ne 0 ]; then
    echo "Error in FeatureCounts step. Exiting."
    exit 1
fi

echo "#########################################"
echo "[Starting Stringtie]"
echo "#########################################"
date

cat bam_loctn.txt | parallel -j 4 "stringtie -L -t -p 4 -B -e -G ${gff_file} -o ${output_folder}/Stringtie/{}/transcripts.gtf -A ${output_folder}/Stringtie/{}/gene_abundances.tsv ${output_folder}/Alignment/{}_sort.bam"

if [ $? -ne 0 ]; then
    echo "Error in Stringtie step. Exiting."
    exit 1
fi

# Clean up intermediate files if needed

echo "Analysis completed successfully."
