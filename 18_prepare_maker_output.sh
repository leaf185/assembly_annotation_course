#!/usr/bin/env bash

#SBATCH --cpus-per-task=20
#SBATCH --mem=40G
#SBATCH --time=1-00:00:00
#SBATCH --job-name=prepare_maker_output
#SBATCH --mail-user=lea.frei@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/lfrei/assembly_annotation_course/output_prepare_maker_%j.o
#SBATCH --error=/data/users/lfrei/assembly_annotation_course/error_prepare_maker_%j.e
#SBATCH --partition=pibu_el8

MAKERBIN="/data/courses/assembly-annotation-course/CDS_annotation/softwares/Maker_v3.01.03/src/bin"
MAKER_OUTPUT="/data/users/lfrei/assembly_annotation_course/gene_annotation"
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
gff="assembly.all.maker.noseq.gff"
protein="assembly.all.maker.fasta.all.maker.proteins.fasta"
transcript="assembly.all.maker.fasta.all.maker.transcripts.fasta"
prefix="Geg-14"

# load modules
module load UCSC-Utils/448-foss-2021a
module load BioPerl/1.7.8-GCCcore-10.3.0
module load MariaDB/10.6.4-GCC-10.3.0

cd $MAKER_OUTPUT

# merge the individual GFF files
$MAKERBIN/gff3_merge -s -d assembly.maker.output/assembly_master_datastore_index.log > assembly.all.maker.gff
$MAKERBIN/gff3_merge -n -s -d assembly.maker.output/assembly_master_datastore_index.log > $gff
$MAKERBIN/fasta_merge -d assembly.maker.output/assembly_master_datastore_index.log -o assembly.all.maker.fasta

# rename genes and transcripts
mkdir -p final
cp $gff final/${gff}.renamed.gff
cp $protein final/${protein}.renamed.fasta 
cp $transcript final/${transcript}.renamed.fasta

cd final

$MAKERBIN/maker_map_ids --prefix $prefix --justify 7 ${gff}.renamed.gff > id.map
$MAKERBIN/map_gff_ids id.map $gff.renamed.gff
$MAKERBIN/map_fasta_ids id.map ${protein}.renamed.fasta
$MAKERBIN/map_fasta_ids id.map ${transcript}.renamed.fasta

# Run InterProScan using the container
apptainer exec \
    --bind $COURSEDIR/data/interproscan-5.70-102.0/data:/opt/interproscan/data \
    --bind $MAKER_OUTPUT \
    --bind $COURSEDIR \
    --bind $SCRATCH:/temp \
    $COURSEDIR/containers/interproscan_latest.sif \
    /opt/interproscan/interproscan.sh \
    -appl pfam --disable-precalc -f TSV \
    --goterms --iprlookup --seqtype p \
    -i ${protein}.renamed.fasta -o output.iprscan


# Get the AED values for the genes
perl $MAKERBIN/AED_cdf_generator.pl -b 0.025 ${gff}.renamed.gff > assembly.all.maker.renamed.gff.AED.txt

# Update the gff file with InterProScan results and filter it for quality
$MAKERBIN/ipr_update_gff ${gff}.renamed.gff output.iprscan > ${gff}.renamed.iprscan.gff

# Filter the gff file based on AED values and Pfam domains
perl /data/users/lfrei/assembly_annotation_course/scripts/maker_quality_filter.pl -a 0.5 ${gff}.renamed.iprscan.gff > ${gff}_iprscan_quality_filtered.gff
# In the above command: -s  Prints transcripts with an AED <1 and/or Pfam domain if in gff3 

# extract AED values from that
perl $MAKERBIN/AED_cdf_generator.pl -b 0.025 ${gff}_iprscan_quality_filtered.gff > assembly.all.maker.renamed.iprscan_quality_filtered.gff.AED.txt

# The gff also contains other features like Repeats, and match hints from different sources of evidence
# Let's see what are the different types of features in the gff file
cut -f3 ${gff}_iprscan_quality_filtered.gff | sort | uniq

# We only want to keep gene features in the third column of the gff file
grep -P "\tgene\t|\tCDS\t|\texon\t|\tfive_prime_UTR\t|\tthree_prime_UTR\t|\tmRNA\t" ${gff}_iprscan_quality_filtered.gff > filtered.genes.renamed.gff3
cut -f3 filtered.genes.renamed.gff3 | sort | uniq

# We need to add back the gff3 header to the filtered gff file so that it can be used by other tools
grep "^#" ${gff}_iprscan_quality_filtered.gff > header.txt
cat header.txt filtered.genes.renamed.gff3 > filtered.genes.renamed.final.gff3

# Get the names of remaining mRNAs and extract them from the transcript and and their proteins from the protein files
grep -P "\tmRNA\t" filtered.genes.renamed.final.gff3 | awk '{print $9}' | cut -d ';' -f1 | sed 's/ID=//g' > mRNA_list.txt
faSomeRecords ${transcript}.renamed.fasta mRNA_list.txt ${transcript}.renamed.filtered.fasta
faSomeRecords ${protein}.renamed.fasta mRNA_list.txt ${protein}.renamed.filtered.fasta