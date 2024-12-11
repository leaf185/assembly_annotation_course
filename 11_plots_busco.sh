#!/usr/bin/env bash

#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --job-name=busco_plots
#SBATCH --mail-user=lea.frei@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/lfrei/assembly_annotation_course/output_busco_plots_%j.o
#SBATCH --error=/data/users/lfrei/assembly_annotation_course/error_busco_plots_%j.e
#SBATCH --partition=pibu_el8

WORK_DIR=/data/users/lfrei/assembly_annotation_course/
INPUT_DIR=/data/users/lfrei/assembly_annotation_course/evaluation
OUTPUT_DIR=/data/users/lfrei/assembly_annotation_course/busco_plots

mkdir -p $OUTPUT_DIR

# copy all the busco short_summary files to the output folder
cp $INPUT_DIR/busco_flye/short_summary.specific.brassicales_odb10.busco_flye.txt $OUTPUT_DIR/.
cp $INPUT_DIR/busco_hifiasm/short_summary.specific.brassicales_odb10.busco_hifiasm.txt $OUTPUT_DIR/.
cp $INPUT_DIR/busco_lja/short_summary.specific.brassicales_odb10.busco_lja.txt $OUTPUT_DIR/.
cp $INPUT_DIR/busco_trinity/short_summary.specific.brassicales_odb10.busco_trinity.txt $OUTPUT_DIR/.

# load the BUSCO module
module load BUSCO/5.4.2-foss-2021a

# move to the output directory and download the generate_plot.py script from the BUSCO GitHub
cd $OUTPUT_DIR
wget https://gitlab.com/ezlab/busco/-/raw/master/scripts/generate_plot.py

python3 generate_plot.py -wd $OUTPUT_DIR