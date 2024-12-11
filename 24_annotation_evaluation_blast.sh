#!/usr/bin/env bash

#SBATCH --cpus-per-task=20
#SBATCH --mem=40G
#SBATCH --time=06:00:00
#SBATCH --job-name=blast_evaluation
#SBATCH --mail-user=lea.frei@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/lfrei/assembly_annotation_course/output_blast_%j.o
#SBATCH --error=/data/users/lfrei/assembly_annotation_course/error_blast_%j.e
#SBATCH --partition=pibu_el8

OUTDIR="/data/users/lfrei/assembly_annotation_course/annotation_evaluation/blast"
WORKDIR="/data/users/lfrei/assembly_annotation_course/gene_annotation/final"
REFDIR="/data/courses/assembly-annotation-course/CDS_annotation/data/uniprot/uniprot_viridiplantae_reviewed.fa"
MAKERBIN="/data/courses/assembly-annotation-course/CDS_annotation/softwares/Maker_v3.01.03/src/bin"

mkdir -p $OUTDIR

# load module
module load BLAST+/2.15.0-gompi-2021a

# create database: this step is already done
#makeblastb -in /data/courses/assembly-annotationcourse/CDS_annotation/data/uniprot/uniprot_viridiplantae_reviewed.fa -dbtype prot

# align proteins of the assembly to the database
blastp -query $WORKDIR/assembly.all.maker.fasta.all.maker.proteins.fasta.renamed.filtered.fasta -db $REFDIR -num_threads 10 -outfmt 6 -evalue 1e-10 -out $OUTDIR/blastp_output

# map the putative functions from blast to the fasta and gff3 files from the MAKER output
cp $WORKDIR/assembly.all.maker.fasta.all.maker.proteins.fasta.renamed.filtered.fasta $WORKDIR/assembly.all.maker.fasta.all.maker.proteins.fasta.renamed.filtered.fasta.Uniprot
cp $WORKDIR/filtered.genes.renamed.final.gff3 $WORKDIR/filtered.genes.renamed.final.gff3.Uniprot
$MAKERBIN/maker_functional_fasta $REFDIR $OUTDIR/blastp_output $WORKDIR/assembly.all.maker.fasta.all.maker.proteins.fasta.renamed.filtered.fasta > $WORKDIR/assembly.all.maker.fasta.all.maker.proteins.fasta.renamed.filtered.fasta.Uniprot
$MAKERBIN/maker_functional_gff $REFDIR $OUTDIR/blastp_output $WORKDIR/filtered.genes.renamed.final.gff3 > $WORKDIR/filtered.genes.renamed.final.gff3.Uniprot