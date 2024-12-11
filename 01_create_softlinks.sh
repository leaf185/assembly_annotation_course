#!/usr/bin/env bash

#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10M
#SBATCH --time=0:15:00
#SBATCH --partition=pibu_el8
#SBATCH --job-name=create_softlink

WORK_DIR=/data/users/lfrei/assembly_annotation_course
DATA_DIR=/data/courses/assembly-annotation-course/raw_data

# create softlinks to the reads for the genome and transcriptome in the working directory
cd $WORK_DIR
ln -s $DATA_DIR/Geg-14 ./
ln -s $DATA_DIR/RNAseq_Sha ./