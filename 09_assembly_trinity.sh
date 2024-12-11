#!/usr/bin/env bash

#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --job-name=assembly_trinity
#SBATCH --mail-user=lea.frei@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/lfrei/assembly_annotation_course/output_trinity_%j.o
#SBATCH --error=/data/users/lfrei/assembly_annotation_course/error_trinity_%j.e
#SBATCH --partition=pibu_el8

WORK_DIR=/data/users/lfrei/assembly_annotation_course/
READS_DIR=/data/users/lfrei/assembly_annotation_course/read_qc/fastp/
OUTPUT_DIR=/data/users/lfrei/assembly_annotation_course/assembly/trinity

mkdir -p $OUTPUT_DIR

# load the trinity module
module load Trinity/2.15.1-foss-2021a

# run the assembly
# option --SS-lib-type RF if the data was stranded
Trinity --seqType fq --left $READS_DIR/RNA_1_fastp.fq --right $READS_DIR/RNA_2_fastp.fq --CPU 6 --max_memory 20G --output $OUTPUT_DIR