#!/usr/bin/env bash

#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --job-name=assembly_flye
#SBATCH --mail-user=lea.frei@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/lfrei/assembly_annotation_course/output_flye_%j.o
#SBATCH --error=/data/users/lfrei/assembly_annotation_course/error_flye_%j.e
#SBATCH --partition=pibu_el8

WORK_DIR=/data/users/lfrei/assembly_annotation_course/
CONTAINER_DIR=/containers/apptainer/flye_2.9.5.sif
READS_DIR=/data/users/lfrei/assembly_annotation_course/Geg-14/ERR11437349.fastq.gz
OUTPUT_DIR=/data/users/lfrei/assembly_annotation_course/assembly/flye

mkdir -p $OUTPUT_DIR

apptainer exec --bind $WORK_DIR $CONTAINER_DIR flye --pacbio-hifi $READS_DIR --out-dir $OUTPUT_DIR

# make a .fai file of the final assembly for the circos plot in TE annotation
module load SAMtools/1.13-GCC-10.3.0
samtools faidx assembly.fasta