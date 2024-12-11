#!/usr/bin/env bash

#SBATCH --cpus-per-task=1
#SBATCH --mem=40G
#SBATCH --time=01:00:00
#SBATCH --job-name=kmer_counting
#SBATCH --mail-user=lea.frei@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/lfrei/assembly_annotation_course/output_kmer_%j.o
#SBATCH --error=/data/users/lfrei/assembly_annotation_course/error_kmer_%j.e
#SBATCH --partition=pibu_el8

WORK_DIR=/data/users/lfrei/assembly_annotation_course/
CONTAINER_DIR=/containers/apptainer/jellyfish:2.2.6--0
READS_DIR=/data/users/lfrei/assembly_annotation_course/read_qc/fastp
OUTPUT_DIR=/data/users/lfrei/assembly_annotation_course/read_qc/kmer_counts

mkdir -p $OUTPUT_DIR

# jellyfish to count the kmer occurrences
apptainer exec --bind $WORK_DIR $CONTAINER_DIR jellyfish count -C -m 21 -s 5G -t 4 $READS_DIR/*.fq -o $OUTPUT_DIR/reads.jf 

# create a histogram of the counts
apptainer exec --bind $WORK_DIR $CONTAINER_DIR jellyfish histo -t 4 -h 1000 $OUTPUT_DIR/reads.jf > $OUTPUT_DIR/reads_3.histo