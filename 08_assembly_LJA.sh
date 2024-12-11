#!/usr/bin/env bash

#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --job-name=assembly_LJA
#SBATCH --mail-user=lea.frei@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/lfrei/assembly_annotation_course/output_LJA_%j.o
#SBATCH --error=/data/users/lfrei/assembly_annotation_course/error_LJA_%j.e
#SBATCH --partition=pibu_el8

WORK_DIR=/data/users/lfrei/assembly_annotation_course/
CONTAINER_DIR=/containers/apptainer/lja-0.2.sif
READS_DIR=/data/users/lfrei/assembly_annotation_course/Geg-14/ERR11437349.fastq.gz
OUTPUT_DIR=/data/users/lfrei/assembly_annotation_course/assembly/LJA

mkdir -p $OUTPUT_DIR

apptainer exec --bind $WORK_DIR $CONTAINER_DIR lja --diploid -o $OUTPUT_DIR --reads $READS_DIR