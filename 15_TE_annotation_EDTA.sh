#!/usr/bin/env bash

#SBATCH --cpus-per-task=20
#SBATCH --mem=100G
#SBATCH --time=1-00:00:00
#SBATCH --job-name=edta_conda
#SBATCH --mail-user=lea.frei@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/lfrei/assembly_annotation_course/output_edta_conda_%j.o
#SBATCH --error=/data/users/lfrei/assembly_annotation_course/error_edta_conda_%j.e
#SBATCH --partition=pibu_el8

WORKDIR="/data/users/lfrei/assembly_annotation_course"
FLYE="$WORKDIR/assembly/flye/assembly.fasta"
OUTDIR="$WORKDIR/EDTA_annotation2"

mkdir -p $OUTDIR


## how to create the environment (before running this script)
# git clone https://github.com/oushujun/EDTA.git
# cd EDTA/
# srun -p pibu_el8 -c 10 --time 02:00:00 --pty bash
# conda env create -f EDTA_2.2.x.yml
# exit the interactive job
# conda activate EDTA2
# sbatch the script


# run EDTA with conda
perl $WORKDIR/EDTA/EDTA.pl \
--genome $FLYE --species others --step all --cds "/data/courses/assembly-annotation-course/CDS_annotation/data/TAIR10_cds_20110103_representative_gene_model_updated" --anno 1 --threads 20