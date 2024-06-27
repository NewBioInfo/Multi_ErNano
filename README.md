# Multi_ErNano
Multi sample bulk RNAseq analysis pipeline for Nanopore reads

Multi_ErNano is a pipeline designed for the analysis of multiple bulk RNA sequences generated using Oxford Nanopore technology. This tool integrates several well-established bioinformatics tools such as "minimap2" for alignment, "featureCounts" for read counting, and "stringTie2" for calculating expression values (FPKM and TPM). Multi_ErNano simplifies the analysis process by allowing batch processing of samples with minimal user input, thereby eliminating the need for manual execution of individual tasks.
Usage

To utilize Multi_ErNano, follow these steps:

    Download
        Clone or download the Multi_ErNano repository to your local machine.

    Installation
        Run Tools_installation.sh in your terminal to ensure all required tools (minimap2, featureCounts, stringTie2) are installed and accessible. 
        Alternatively, install these tools manually from their respective websites and ensure they are added to your PATH for easy execution.

    Data Preparation
        Organize your raw sequencing data (in fastq or fastq.gz format) into a folder.
        Prepare a GTF file containing gene annotations.
        Create a BED file using minimap2-master/misc/paftools.js gff2bed ZZZ.gtf > ZZZ.bed where "ZZZ.gtf" is your gene annotation file. 
        Download the minimap2-master folder from minimap2 GitHub.

    Execution
        Execute Multi_ErNano.sh with the following parameters:
            -o: Output folder path where analysis results will be saved.
            -G: Genome file in FASTA format.
            -gtf: GTF file containing gene locations.
            -gff: GFF3 file.
            -fq: Path to the folder containing fastq/fastq.gz files.
            -bed: Path to the BED file created in step 3.
            -t: Number of threads (CPU cores) to use.
            -RAM: Amount of RAM in GB to allocate for the process.

    Output
        The pipeline will generate the following output folders:
            Alignment: Contains BAM files (ZZZ_sor.bam and ZZZ_sort.bam.bai) suitable for visualization in tools like IGV.
            FeatureCounts: Includes ZZZ.tsv and ZZZ.tsv.summary files with read counts per exon.
            StringTie: A folder named ZZZ containing various files including gene_abundances.tsv, transcripts.gtf, and other outputs for downstream analysis.
            **ZZZ = is the name taken from fastq file name.

    Performance
        Depending on the number and size of input files, execution time may vary. The pipeline aims to automate tasks that would otherwise require manual execution.

# Citation

This script is provided by ATGC Bioinformatics Services for the benefit of early-stage biological scientists, aiming to facilitate RNA-seq data analysis without extensive coding requirements. If you find Multi_ErNano useful, please support its development and maintenance by citing it appropriately (DOI: 10.5281/zenodo.12559922). Additionally, cite the individual tools (minimap2, featureCounts, stringTie2) used within the pipeline for their contributions.
Contact

For comments, suggestions, or bug reports, please contact admin@atgcbioinfo.com.
