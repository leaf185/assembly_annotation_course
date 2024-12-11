#!/usr/bin/env bash

#SBATCH --cpus-per-task=20
#SBATCH --mem=40G
#SBATCH --time=06:00:00
#SBATCH --job-name=conceptualise_omark
#SBATCH --mail-user=lea.frei@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/lfrei/assembly_annotation_course/output_omark_%j.o
#SBATCH --error=/data/users/lfrei/assembly_annotation_course/error_omark_%j.e
#SBATCH --partition=pibu_el8

WORKDIR="/data/users/lfrei/assembly_annotation_course/annotation_evaluation/omark"
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"

mkdir -p $WORKDIR
cd $WORKDIR

# download the missing and fragmented Hierarchical Orthologous groups (HOGs)
$COURSEDIR/softwares/OMArk-0.3.0/utils/omark_contextualize.py fragment -m $WORKDIR/assembly.all.maker.proteins.renamed.filtered.fasta.omamer -o $WORKDIR/omark_output -f fragment_HOGs
$COURSEDIR/softwares/OMArk-0.3.0/utils/omark_contextualize.py missing -m $WORKDIR/assembly.all.maker.proteins.renamed.filtered.fasta.omamer -o $WORKDIR/omark_output -f missing_HOGs 