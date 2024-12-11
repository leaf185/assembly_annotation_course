#!/usr/bin/env bash

#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --job-name=quast_evaluation
#SBATCH --mail-user=lea.frei@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/lfrei/assembly_annotation_course/output_quast_%j.o
#SBATCH --error=/data/users/lfrei/assembly_annotation_course/error_quast%j.e
#SBATCH --partition=pibu_el8

WORK_DIR=/data/users/lfrei/assembly_annotation_course/
INPUT_DIR=/data/users/lfrei/assembly_annotation_course/assembly
OUTPUT_DIR=/data/users/lfrei/assembly_annotation_course/evaluation
REFERENCE_DIR=/data/courses/assembly-annotation-course/references/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa
GENES_DIR=/data/courses/assembly-annotation-course/references/TAIR10_GFF3_genes.gff
CONTAINER_DIR=/containers/apptainer/quast_5.2.0.sif

mkdir -p $OUTPUT_DIR/quast_with_ref
mkdir -p $OUTPUT_DIR/quast_no_ref

# run QUAST on each of the 3 genome assemblies
# with reference
apptainer exec --bind /data $CONTAINER_DIR \
quast.py -o $OUTPUT_DIR/quast_with_ref -r $REFERENCE_DIR --features $GENES_DIR --threads 4 --labels flye,hifiasm,LJA --eukaryote --no-sv $INPUT_DIR/flye/assembly.fasta $INPUT_DIR/hifiasm/Geg-14.asm.bp.p_ctg.fa $INPUT_DIR/LJA/assembly.fasta

# without reference
apptainer exec --bind /data $CONTAINER_DIR \
quast.py -o $OUTPUT_DIR/quast_no_ref --est-ref-size 130000000 --threads 4 --labels flye,hifiasm,LJA --eukaryote --no-sv $INPUT_DIR/flye/assembly.fasta $INPUT_DIR/hifiasm/Geg-14.asm.bp.p_ctg.fa $INPUT_DIR/LJA/assembly.fasta