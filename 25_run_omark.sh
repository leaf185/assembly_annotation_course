#!/usr/bin/env bash

#SBATCH --cpus-per-task=20
#SBATCH --mem=40G
#SBATCH --time=06:00:00
#SBATCH --job-name=run_omark
#SBATCH --mail-user=lea.frei@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/lfrei/assembly_annotation_course/output_omark_%j.o
#SBATCH --error=/data/users/lfrei/assembly_annotation_course/error_omark_%j.e
#SBATCH --partition=pibu_el8

WORKDIR="/data/users/lfrei/assembly_annotation_course/annotation_evaluation/omark"
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
protein="/data/users/lfrei/assembly_annotation_course/gene_annotation/final/assembly.all.maker.fasta.all.maker.proteins.fasta.renamed.filtered.fasta"

mkdir -p $WORKDIR

cd $WORKDIR

# create the isoforms file
grep '^>' $protein | cut -c2- | cut -f1 -d" " | sort | \
awk 'BEGIN { ORS=""; OFS="" } NR == 1 {print $1 }; NR > 1 {gene = substr($1,1,14); if (gene == last_gene){print ";", $1} else {print "\n", $1}; last_gene = gene}' > isoform_list.txt

# get the environment from Andrew (run in an interactive job before submitting the script)
#eval "$(/home/amaalouf/miniconda3/bin/conda shell.bash hook)"
#conda activate OMArk

# also install omadb and gffutils module
#pip install omadb
#pip install gffutils

# download the database 
wget https://omabrowser.org/All/LUCA.h5

# run omamer and omark
omamer search --db LUCA.h5 --query ${protein} --out $WORKDIR/assembly.all.maker.proteins.renamed.filtered.fasta.omamer

omark -f assembly.all.maker.proteins.renamed.filtered.fasta.omamer -of ${protein} -i isoform_list.txt -d LUCA.h5 -o omark_output