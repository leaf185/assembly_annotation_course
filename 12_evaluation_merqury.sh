#!/usr/bin/env bash

#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --job-name=merqury_evaluation
#SBATCH --mail-user=lea.frei@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/lfrei/assembly_annotation_course/output_merqury_%j.o
#SBATCH --error=/data/users/lfrei/assembly_annotation_course/error_merqury_%j.e
#SBATCH --partition=pibu_el8

WORK_DIR=/data/users/lfrei/assembly_annotation_course/
INPUT_DIR=/data/users/lfrei/assembly_annotation_course/assembly
READS_DIR=/data/users/lfrei/assembly_annotation_course/Geg-14/ERR11437349.fastq.gz
OUTPUT_DIR=/data/users/lfrei/assembly_annotation_course/evaluation/merqury
CONTAINER_DIR=/containers/apptainer/merqury_1.3.sif

mkdir -p $OUTPUT_DIR

export MERQURY="/usr/local/share/merqury"

# find the optimal value for k
#apptainer exec --bind $WORK_DIR $CONTAINER_DIR \
#sh $MERQURY/best_k.sh 130000000

# prepare the meryl database
# k=18 comes from the output of the first step (tolerable collision rate: 0.001, 18.4591)
apptainer exec --bind $WORK_DIR $CONTAINER_DIR \
meryl k=18 count $READS_DIR output $OUTPUT_DIR/genome.meryl

# run merqury on each of the 3 genome assemblies

cd $OUTPUT_DIR
apptainer exec --bind $WORK_DIR $CONTAINER_DIR \
sh $MERQURY/merqury.sh $OUTPUT_DIR/genome.meryl $INPUT_DIR/flye/assembly.fasta flye

cd $OUTPUT_DIR
apptainer exec --bind $WORK_DIR $CONTAINER_DIR \
sh $MERQURY/merqury.sh $OUTPUT_DIR/genome.meryl $INPUT_DIR/hifiasm/Geg-14.asm.bp.p_ctg.fa hifiasm

# rename the LJA assembly so it does not get confounded with the flye assembly
mv $INPUT_DIR/LJA/assembly.fasta $INPUT_DIR/LJA/lja_assembly.fasta

cd $OUTPUT_DIR
apptainer exec --bind $WORK_DIR $CONTAINER_DIR \
sh $MERQURY/merqury.sh $OUTPUT_DIR/genome.meryl $INPUT_DIR/LJA/lja_assembly.fasta LJA

# change the name back to assembly.fasta so all other scripts still work
mv $INPUT_DIR/LJA/lja_assembly.fasta $INPUT_DIR/LJA/assembly.fasta