#!/usr/bin/env bash

#SBATCH --cpus-per-task=1
#SBATCH --mem=40G
#SBATCH --time=01:00:00
#SBATCH --job-name=fastqc_transcriptome
#SBATCH --mail-user=lea.frei@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/lfrei/assembly_annotation_course/output_fastqc_transcriptome_%j.o
#SBATCH --error=/data/users/lfrei/assembly_annotation_course/error_fastqc_transcriptome_%j.e
#SBATCH --partition=pibu_el8

WORK_DIR=/data/users/lfrei/assembly_annotation_course/
CONTAINER_DIR=/containers/apptainer/fastqc-0.12.1.sif
READS_DIR=/data/users/lfrei/assembly_annotation_course/RNAseq_Sha/
OUTPUT_DIR=/data/users/lfrei/assembly_annotation_course/read_qc/fastqc

mkdir -p $OUTPUT_DIR

# run fastqc on the transcriptomic reads
apptainer exec --bind $WORK_DIR $CONTAINER_DIR fastqc --outdir $OUTPUT_DIR $READS_DIR/*