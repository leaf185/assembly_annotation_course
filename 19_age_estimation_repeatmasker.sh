#!/usr/bin/env bash

#SBATCH --cpus-per-task=4
#SBATCH --mem=20G
#SBATCH --time=01:00:00
#SBATCH --job-name=estimate_age_repeatmasker
#SBATCH --mail-user=lea.frei@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/lfrei/assembly_annotation_course/output_repeatmasker_%j.o
#SBATCH --error=/data/users/lfrei/assembly_annotation_course/error_repeatmasker_%j.e
#SBATCH --partition=pibu_el8

WORKDIR="/data/users/lfrei/assembly_annotation_course/EDTA_annotation"
INPUTDIR="/data/users/lfrei/assembly_annotation_course/EDTA_annotation/assembly.fasta.mod.EDTA.anno"
SCRIPTDIR="/data/users/lfrei/assembly_annotation_course/scripts"

cd $WORKDIR

# download the perl script from github
wget -P $SCRIPTDIR https://raw.githubusercontent.com/4ureliek/Parsing-RepeatMasker-Outputs/master/parseRM.pl

# make it executable
chmod +x $SCRIPTDIR/parseRM.pl

# load the module and run the script
module add BioPerl/1.7.8-GCCcore-10.3.0
perl $SCRIPTDIR/parseRM.pl -i $INPUTDIR/assembly.fasta.mod.out -l 50,1 -v > $INPUTDIR/parsed_TE_divergence_output.tsv