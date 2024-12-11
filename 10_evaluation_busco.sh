#!/usr/bin/env bash

#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --job-name=busco_evaluation
#SBATCH --mail-user=lea.frei@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/lfrei/assembly_annotation_course/output_busco_%j.o
#SBATCH --error=/data/users/lfrei/assembly_annotation_course/error_busco_%j.e
#SBATCH --partition=pibu_el8

WORK_DIR=/data/users/lfrei/assembly_annotation_course/
INPUT_DIR=/data/users/lfrei/assembly_annotation_course/assembly
OUTPUT_DIR=/data/users/lfrei/assembly_annotation_course/evaluation

mkdir -p $OUTPUT_DIR/busco_flye
mkdir -p $OUTPUT_DIR/busco_hifiasm
mkdir -p $OUTPUT_DIR/busco_lja
mkdir -p $OUTPUT_DIR/busco_trinity

# load the BUSCO module
module load BUSCO/5.4.2-foss-2021a

# run BUSCO on each of the 4 assemblies
busco -i $INPUT_DIR/flye/assembly.fasta -m genome --lineage_dataset brassicales_odb10 --cpu 4 -o $OUTPUT_DIR/busco_flye -f
busco -i $INPUT_DIR/hifiasm/Geg-14.asm.bp.p_ctg.fa -m genome --lineage_dataset brassicales_odb10 --cpu 4 -o $OUTPUT_DIR/busco_hifiasm -f
busco -i $INPUT_DIR/LJA/assembly.fasta -m genome --lineage_dataset brassicales_odb10 --cpu 4 -o $OUTPUT_DIR/busco_lja -f
busco -i $INPUT_DIR/trinity.Trinity.fasta -m transcriptome --lineage_dataset brassicales_odb10 --cpu 4 -o $OUTPUT_DIR/busco_trinity -f