#!/usr/bin/env bash

#SBATCH --cpus-per-task=1
#SBATCH --mem=40G
#SBATCH --time=01:00:00
#SBATCH --job-name=fastp
#SBATCH --mail-user=lea.frei@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/lfrei/assembly_annotation_course/output_fastp_%j.o
#SBATCH --error=/data/users/lfrei/assembly_annotation_course/error_fastp_%j.e
#SBATCH --partition=pibu_el8

WORK_DIR=/data/users/lfrei/assembly_annotation_course/
CONTAINER_DIR=/containers/apptainer/fastp_0.23.2--h5f740d0_3.sif
READS_DIR_RNA=/data/users/lfrei/assembly_annotation_course/RNAseq_Sha/
READS_DIR_DNA=/data/users/lfrei/assembly_annotation_course/Geg-14/ERR11437349.fastq.gz
OUTPUT_DIR=/data/users/lfrei/assembly_annotation_course/read_qc/fastp

mkdir -p $OUTPUT_DIR

# run fastp on the genome reads (no quality filtering)
apptainer exec --bind $WORK_DIR $CONTAINER_DIR fastp -i $READS_DIR_DNA -o $OUTPUT_DIR/DNA_fastp.fq --disable_quality_filtering --disable_length_filtering --html $OUTPUT_DIR/fastp_DNA.html

# run fastp on the transcriptome reads (with filtering)
apptainer exec --bind $WORK_DIR $CONTAINER_DIR fastp -i $READS_DIR_RNA/ERR754081_1.fastq.gz -o $OUTPUT_DIR/RNA_1_fastp.fq -I $READS_DIR_RNA/ERR754081_2.fastq.gz -O $OUTPUT_DIR/RNA_2_fastp.fq --html $OUTPUT_DIR/fastp_RNA.html