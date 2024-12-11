#!/usr/bin/env bash

#SBATCH --cpus-per-task=20
#SBATCH --mem=40G
#SBATCH --time=06:00:00
#SBATCH --job-name=run_genespace
#SBATCH --mail-user=lea.frei@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/lfrei/assembly_annotation_course/output_genespace_%j.o
#SBATCH --error=/data/users/lfrei/assembly_annotation_course/error_genespace_%j.e
#SBATCH --partition=pibu_el8

WORKDIR="/data/users/lfrei/assembly_annotation_course"
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"

apptainer exec --bind $COURSEDIR --bind $WORKDIR --bind "$SCRATCH:/temp" "$COURSEDIR/containers/genespace_latest.sif" Rscript "$WORKDIR/scripts/28_genespace.R" $WORKDIR/annotation_evaluation/genespace

# parse the orthofinder output
apptainer exec --bind /data/courses/assembly-annotation-course/CDS_annotation/ --bind /data/users/lfrei/assembly_annotation_course/ --bind $SCRATCH:/temp /data/courses/assembly-annotation-course/CDS_annotation/containers/genespace_latest.sif Rscript /data/users/lfrei/assembly_annotation_course/scripts/28_parse_orthofinder.R