#!/usr/bin/env bash

#SBATCH --cpus-per-task=20
#SBATCH --mem=40G
#SBATCH --time=06:00:00
#SBATCH --job-name=genespace_folders
#SBATCH --mail-user=lea.frei@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/lfrei/assembly_annotation_course/output_genespace_%j.o
#SBATCH --error=/data/users/lfrei/assembly_annotation_course/error_genespace_%j.e
#SBATCH --partition=pibu_el8

WORKDIR="/data/users/lfrei/assembly_annotation_course"
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
FAI_FILE="/data/users/lfrei/assembly_annotation_course/assembly/flye/assembly.fasta.fai"
GENE_FILE="/data/users/lfrei/assembly_annotation_course/gene_annotation/final/filtered.genes.renamed.final.gff3"
PROTEIN_FILE="/data/users/lfrei/assembly_annotation_course/gene_annotation/final/assembly.all.maker.fasta.all.maker.proteins.fasta.renamed.filtered.longest.fasta"

# load modules
module load SeqKit/2.6.1

mkdir -p $WORKDIR/annotation_evaluation/genespace/peptide
mkdir -p $WORKDIR/annotation_evaluation/genespace/bed

cd $WORKDIR/annotation_evaluation/genespace

## prepare the input files
# get 20 longest contigs
sort -k2,2 $FAI_FILE | cut -f1 | head -n20 > longest_contigs.txt

# create a bed file of all genes in the 20 longest contigs
grep -f longest_contigs.txt $GENE_FILE | awk 'NR > 1 && $3 == "gene" {gene_name = substr($9, 4, 13); print $1, $4, $5, gene_name}' > bed/genome1.bed

# create a fasta file of these proteins
cut -f4 -d" " bed/genome1.bed > gene_list.txt
sed 's/-R.*//' $PROTEIN_FILE | seqkit grep -f gene_list.txt > peptide/genome1.fa

# copy the reference Arabidopsis files
cp $COURSEDIR/data/TAIR10.bed bed/
cp $COURSEDIR/data/TAIR10.fa peptide/

# copy the files from accession Kar-1 to compare
cp /data/users/okopp/assembly_annotation_course/genespace/bed/genome1.bed annotation_evaluation/genespace/bed/genome2.bed
cp /data/users/okopp/assembly_annotation_course/genespace/peptide/genome1.fa annotation_evaluation/genespace/peptide/genome2.fa