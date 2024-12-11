#!/usr/bin/env bash

#SBATCH --cpus-per-task=20
#SBATCH --mem=40G
#SBATCH --time=1-00:00:00
#SBATCH --job-name=run_miniprot
#SBATCH --mail-user=lea.frei@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/lfrei/assembly_annotation_course/output_miniprot_%j.o
#SBATCH --error=/data/users/lfrei/assembly_annotation_course/error_miniprot_%j.e
#SBATCH --partition=pibu_el8

WORKDIR="/data/users/lfrei/assembly_annotation_course"
GENOMIC_FASTA="/data/users/lfrei/assembly_annotation_course/assembly/flye/assembly.fasta"
SEQ_FASTA1="/data/users/lfrei/assembly_annotation_course/annotation_evaluation/omark/fragment_HOGs"
SEQ_FASTA2="/data/users/lfrei/assembly_annotation_course/annotation_evaluation/omark/missing_HOGs.fa"
MINIPROT_OUTPUT="/data/users/lfrei/assembly_annotation_course/annotation_evaluation/miniprot"

mkdir -p $MINIPROT_OUTPUT

cd $WORKDIR

# download and compile miniprot
git clone https://github.com/lh3/miniprot
cd miniprot && make

# run miniprot
/data/users/lfrei/assembly_annotation_course/miniprot/miniprot -I --gff --outs=0.95 ${GENOMIC_FASTA} ${SEQ_FASTA1} > ${MINIPROT_OUTPUT}/miniprot_fragments.gff
/data/users/lfrei/assembly_annotation_course/miniprot/miniprot -I --gff --outs=0.95 ${GENOMIC_FASTA} ${SEQ_FASTA2} > ${MINIPROT_OUTPUT}/miniprot_missing.gff