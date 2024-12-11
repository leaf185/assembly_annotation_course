#!/usr/bin/env bash

#SBATCH --cpus-per-task=20
#SBATCH --mem=40G
#SBATCH --time=1-00:00:00
#SBATCH --job-name=TEsorter
#SBATCH --mail-user=lea.frei@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/lfrei/assembly_annotation_course/output_TEsorter_%j.o
#SBATCH --error=/data/users/lfrei/assembly_annotation_course/error_TEsorter_%j.e
#SBATCH --partition=pibu_el8

WORKDIR=/data/users/lfrei/assembly_annotation_course
CONTAINERDIR=/data/courses/assembly-annotation-course/containers2/TEsorter_1.3.0.sif

cd $WORKDIR/EDTA_annotation
module load SeqKit/2.6.1

# Extract Copia sequences
seqkit grep -r -p "Copia" assembly.fasta.mod.EDTA.TElib.fa > Copia_sequences.fa

# Extract Gypsy sequences
seqkit grep -r -p "Gypsy" assembly.fasta.mod.EDTA.TElib.fa > Gypsy_sequences.fa

# run TEsorter
apptainer exec -C -H $WORKDIR -H ${pwd}:/work --writable-tmpfs -u $CONTAINERDIR TEsorter Copia_sequences.fa -db rexdb-plant

apptainer exec -C -H $WORKDIR -H ${pwd}:/work --writable-tmpfs -u $CONTAINERDIR TEsorter Gypsy_sequences.fa -db rexdb-plant