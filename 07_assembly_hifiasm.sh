#!/usr/bin/env bash

#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --job-name=assembly_hifiasm
#SBATCH --mail-user=lea.frei@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/lfrei/assembly_annotation_course/output_hifiasm_%j.o
#SBATCH --error=/data/users/lfrei/assembly_annotation_course/error_hifiasm_%j.e
#SBATCH --partition=pibu_el8

WORK_DIR=/data/users/lfrei/assembly_annotation_course/
CONTAINER_DIR=/containers/apptainer/hifiasm_0.19.9.sif
READS_DIR=/data/users/lfrei/assembly_annotation_course/Geg-14/ERR11437349.fastq.gz
OUTPUT_DIR=/data/users/lfrei/assembly_annotation_course/assembly/hifiasm

mkdir -p $OUTPUT_DIR

apptainer exec --bind $WORK_DIR $CONTAINER_DIR hifiasm -o $OUTPUT_DIR/Geg-14.asm -t 32 $READS_DIR

# change the output to fasta format
awk '/^S/{print ">"$2;print $3}' $OUTPUT_DIR/Geg-14.asm.bp.p_ctg.gfa > $OUTPUT_DIR/Geg-14.asm.bp.p_ctg.fa