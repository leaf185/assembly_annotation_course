setwd("C:/Users/freil/Documents/1_Studium/24_HS/genome_annotation/")

# Comparing identity percentages ------------

library(tidyverse)
library(data.table)

# Load the data
anno_data <- read.table("C:/Users/freil/Documents/1_Studium/24_HS/genome_annotation/assembly.fasta.mod.LTR.intact.raw.gff3", header = F, sep = "\t")
head(anno_data)
# Get the classification table
classification <- data.table::fread("C:/Users/freil/Documents/1_Studium/24_HS/genome_annotation/assembly.fasta.mod.LTR.intact.raw.fa.anno.list")
head(classification)

# Separate first column into two columns at "#", name the columns "Name" and "Classification"
names(classification)[1] <- "TE"
classification <- classification %>% separate(TE, into = c("Name", "Classification"), sep = "#")


# Check the superfamilies present in the GFF3 file, and their counts
anno_data$V3 %>% table()

# Filter the data to select only TE superfamilies, (long_terminal_repeat, repeat_region and target_site_duplication are features of TE)
anno_data_filtered <- anno_data[!anno_data$V3 %in% c("long_terminal_repeat", "repeat_region", "target_site_duplication"), ]
nrow(anno_data_filtered)
# QUESTION: How Many TEs are there in the annotation file?
# there are 285 rows, so that's probably the number of TEs

# Check the Clades present in the GFF3 file, and their counts
# select the feature column V9 and get the Name and Identity of the TE
anno_data_filtered$named_lists <- lapply(anno_data_filtered$V9, function(line) {
  setNames(
    sapply(strsplit(strsplit(line, ";")[[1]], "="), `[`, 2),
    sapply(strsplit(strsplit(line, ";")[[1]], "="), `[`, 1)
  )
})

anno_data_filtered$Name <- unlist(lapply(anno_data_filtered$named_lists, function(x) {
  x["Name"]
}))

anno_data_filtered$Identity <- unlist(lapply(anno_data_filtered$named_lists, function(x) {
  x["ltr_identity"]
}))

anno_data_filtered$length <- anno_data_filtered$V5 - anno_data_filtered$V4

anno_data_filtered <- anno_data_filtered %>% select(V1, V4, V5, V3, Name, Identity, length)
head(anno_data_filtered)

# Merge the classification table with the annotation data
anno_data_filtered_classified <- merge(anno_data_filtered, classification, by = "Name", all.x = T)

table(anno_data_filtered_classified$Superfamily)
# QUESTION: Most abundant superfamilies are? Copia, 148 elements

table(anno_data_filtered_classified$Clade)
# QUESTION: Most abundant clades are? Ale, 58 elements


# Now plot the distribution of TE percent identity per clade

anno_data_filtered_classified$Identity <- as.numeric(as.character(anno_data_filtered_classified$Identity))

anno_data_filtered_classified$Clade <- as.factor(anno_data_filtered_classified$Clade)

# Create a f plots for each Superfamily
ggplot(anno_data_filtered_classified, aes(x = Identity)) +
  geom_histogram(color = "black", fill = "grey") +
  facet_grid(Superfamily ~ .) +
  cowplot::theme_cowplot()
# copia has more at identity pretty much 1, then both spread out a bit to 0.95 and very few to even lower (0.9)


# Create plots for each clade
ggplot(anno_data_filtered_classified[anno_data_filtered_classified$Superfamily != "unknown", ], aes(x = Identity, fill = Superfamily)) +
  geom_histogram(color = "black") +
  scale_y_continuous(breaks = c(0,10)) +
  facet_grid(Clade ~ Superfamily, drop = T) +
  cowplot::theme_cowplot() +
  theme(strip.text.y = element_text(angle = 0), legend.position = "none")

# Circos plot ----------------
# Load the circlize package
library(circlize)
library(tidyverse)
library(ComplexHeatmap)

# Load the TE annotation GFF3 file
gff_file <- "C:/Users/freil/Documents/1_Studium/24_HS/genome_annotation/assembly.fasta.mod.EDTA.TEanno.gff3"
gff_data <- read.table(gff_file, header = F, sep = "\t", stringsAsFactors = FALSE)
colnames(gff_data) <- c("seqid", "EDTA", "Superfamily", "start", "end", "V6", "strand", "V8", "attributes")
gff_data <- gff_data %>%
  mutate(name = gsub(".*;Name=(.+)[;;][Cc]lassification.*", "\\1", attributes))

# Check the superfamilies present in the GFF3 file, and their counts
gff_data$Superfamily %>% table()

# add the Clades
# add CRM and Athila
clade_data <- readr::read_tsv("Gypsy_sequences.fa.rexdb-plant.cls.tsv", col_names = T)
clade_data <- clade_data %>%
  mutate(name = sub("#.*", "", `#TE`))

# match the clade data to the gff dataframe
gff_data <- left_join(gff_data, clade_data, by = 'name')

# get the fai data
fai_data <- read.table("assembly.fasta.fai", header = FALSE, stringsAsFactors = FALSE)
colnames(fai_data) <- c("scaffold", "length", "offset", "linebases", "linewidth")

# Choose the top N longest scaffolds (e.g., top 10 or top 20)
N <- 20
top_scaffolds <- head(fai_data[order(-fai_data$length), ], N)

# Create a custom ideogram data frame with scaffold, start, and end positions
ideogram_data <- data.frame(
  scaffold = top_scaffolds$scaffold,
  start = 1,
  end = top_scaffolds$length)

# filter the TE data for longest scaffolds
gff_data <- gff_data[gff_data$seqid %in% top_scaffolds$scaffold, ]

# Initialize the circos plot with the custom ideogram
circos.genomicInitialize(ideogram_data, plotType = "axis")

# Assign specific colors to each superfamily
top_superfamilies <- c("Copia_LTR_retrotransposon", "Gypsy_LTR_retrotransposon", "Mutator_TIR_transposon", "CACTA_TIR_transposon", "CRM", "Athila")
superfamily_colors <- c("red", "green", "yellow", "orange", "darkblue", "lightblue")
names(superfamily_colors) <- top_superfamilies

# Plot the density of each TE superfamily
for (superfamily in top_superfamilies[1:4]) {
  # Filter the TE data for the current superfamily
  te_subset <- gff_data[gff_data$Superfamily.x == superfamily, ]
  
  # Plot TE density for this superfamily
  circos.genomicDensity(te_subset[, c("seqid", "start", "end")], 
                        col = superfamily_colors[superfamily], 
                        track.height = 0.08, 
                        window.size = 1e5)  
}

# Plot the density of the clades
for (superfamily in top_superfamilies[5:6]) {
  # Filter the TE data for the current superfamily
  te_subset <- gff_data[gff_data$Clade == superfamily, ]
  
  # Plot TE density for this superfamily
  circos.genomicDensity(te_subset[, c("seqid", "start", "end")], 
                        col = superfamily_colors[superfamily], 
                        track.height = 0.08, 
                        window.size = 1e5)  
}

# load the gene annotation gff and add it to the plot
gene_file <- "C:/Users/freil/Documents/1_Studium/24_HS/genome_annotation/filtered.genes.renamed.gff3"
gene_data <- read.table(gene_file, header = F, sep = "\t", stringsAsFactors = FALSE)
gene_data <- gene_data %>%
  dplyr::filter(V3 == "gene") %>%
  select(V1, V4, V5) %>%
  rename("seqid" = V1, "start" = V4, "end" = V5) %>%
  filter(seqid %in% top_scaffolds$scaffold)

circos.genomicDensity(gene_data, 
                      col = "purple", 
                      track.height = 0.08, 
                      window.size = 1e5)

# add a legend
legend("topleft", legend = c(top_superfamilies, "gene density"), fill = c(superfamily_colors, "purple"), cex = 0.4)

# Copia is kinda everywhere
#Gypsy is probably more at the centromeres
#CRM does have ca 5 peaks which could be the centromeres of each of the 5 chromosomes
# mutator and cacta are also kind of everywhere

# TE clade abundance ----
copia_data <- readr::read_tsv("C:/Users/freil/Documents/1_Studium/24_HS/genome_annotation/Copia_sequences.fa.rexdb-plant.cls.tsv", col_names = T)
gypsy_data <- readr::read_tsv("C:/Users/freil/Documents/1_Studium/24_HS/genome_annotation/Gypsy_sequences.fa.rexdb-plant.cls.tsv", col_names = T)
overview_data <- readr::read_tsv("C:/Users/freil/Documents/1_Studium/24_HS/genome_annotation/assembly.fasta.mod.EDTA.TEanno.sum", col_names = T, skip = 5, n_max = 22)
sum_data <- readr::read_table("C:/Users/freil/Documents/1_Studium/24_HS/genome_annotation/assembly.fasta.mod.EDTA.TEanno.sum", col_names = F, skip = 34)
colnames(sum_data) <- c("name", "Count", "bpMasked", "%Masked")

# get the name as a separate column in copia and gypsy data
copia_data <- copia_data  %>%
  mutate(name = sub("#.*", "", copia_data$`#TE`)) %>%
  filter(!is.na(name))
gypsy_data <- gypsy_data  %>%
  mutate(name = sub("#.*", "", gypsy_data$`#TE`)) %>%
  filter(!is.na(name))

sum_data <- sum_data[!is.na(sum_data$name), 1:4]
# match the sum_data to copia and gypsy
all_data <- copia_data %>%
  bind_rows(gypsy_data) %>%
  right_join(sum_data, by = 'name')

# plot abundance of each clade
# barplot with number of elements in each clade
all_data %>%
  filter(!is.na(Clade)) %>%
  group_by(Clade) %>%
  summarise(total_value = sum(Count)) %>%
  ggplot(aes(x = Clade, y = total_value, fill = Clade)) +
  geom_bar(stat = "identity") +
  labs(title = "Count of Observations per Clade", x = "Clade", y = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# barplot with number of bp covered by elements of each clade
df <- all_data %>%
  filter(!is.na(Clade)) %>%
  group_by(Clade) %>%
  summarise(total_value = sum(bpMasked))
ggplot(df, aes(x = Clade, y = total_value, fill = Clade)) +
  geom_bar(stat = "identity") +
  labs(x = "Clade", y = "Total Value", title = "bp covered by Clade") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# separate plots for clades from Copia or Gypsy superfamily
all_data %>%
  filter(!is.na(Clade)) %>%
  filter(Superfamily == "Copia") %>%
  group_by(Clade) %>%
  summarise(total_value = sum(Count)) %>%
  ggplot(aes(x = Clade, y = total_value, fill = Clade)) +
  geom_bar(stat = "identity") +
  labs(title = "Count of Observations per Clade in Copia superfamily", x = "Clade", y = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

all_data %>%
  filter(!is.na(Clade)) %>%
  filter(Superfamily == "Gypsy") %>%
  group_by(Clade) %>%
  summarise(total_value = sum(Count)) %>%
  ggplot(aes(x = Clade, y= total_value, fill = Clade)) +
  geom_bar(stat = "identity") +
  labs(title = "Count of Observations per Clade in Gypsy superfamily", x = "Clade", y = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Landscape plot ---------
library(reshape2)
library(hrbrthemes)
library(tidyverse)
library(data.table)

# get data from parameter
data <- "assembly.fasta.mod.out.landscape.Div.Rname.tab"

rep_table <- fread(data, header = FALSE, sep = "\t")
rep_table %>% head()
# How does the data look like?
# for each TE, there is the class and superfamily and then numbers

colnames(rep_table) <- c("Rname", "Rclass", "Rfam", 1:50)
rep_table <- rep_table %>% filter(Rfam != "unknown")
rep_table$fam <- paste(rep_table$Rclass, rep_table$Rfam, sep = "/")

table(rep_table$fam)
# How many elements are there in each Superfamily?
# between 1 and 156

rep_table.m <- melt(rep_table)

rep_table.m <- rep_table.m[-c(which(rep_table.m$variable == 1)), ] # remove the peak at 1, as the library sequences are copies in the genome, they inflate this low divergence peak

# Arrange the data so that they are in the following order:
# LTR/Copia, LTR/Gypsy, all types of DNA transposons (TIR transposons), DNA/Helitron, all types of MITES
rep_table.m$fam <- factor(rep_table.m$fam, levels = c(
  "LINE/L1", "LTR/Copia", "LTR/Gypsy", "DNA/DTA", "DNA/DTC", "DNA/DTH", "DNA/DTM", "DNA/DTT", "DNA/Helitron", "MITE/DTA", "MITE/DTC", "MITE/DTH", "MITE/DTM", "MITE/DTT"
))

# NOTE: Check that all the superfamilies in your dataset are included above

rep_table.m$distance <- as.numeric(rep_table.m$variable) / 100 # as it is percent divergence

# Question:
# rep_table.m$age <- ??? # Calculate using the substitution rate and the formula provided in the tutorial
substitution_rate <- 8.22 * 10^(-9)
rep_table.m$age <- rep_table.m$distance / 2*substitution_rate


# options(scipen = 999)

# remove helitrons as EDTA is not able to annotate them properly (https://github.com/oushujun/EDTA/wiki/Making-sense-of-EDTA-usage-and-outputs---Q&A)
rep_table.m <- rep_table.m %>% filter(fam != "DNA/Helitron") %>%
  rename("family" = fam)

ggplot(rep_table.m, aes(fill = family, x = distance, weight = value / 1000000)) +
  geom_bar() +
  cowplot::theme_cowplot() +
  scale_fill_brewer(palette = "Paired") +
  xlab("Distance") +
  ylab("Sequence (Mbp)") +
  theme(axis.text.x = element_text(angle = 90, vjust = 1, size = 9, hjust = 1), plot.title = element_text(hjust = 0.5))

#ggsave(filename = "Plots/output.pdf", width = 10, height = 5, useDingbats = F)


# Question: Now can you get separate plots for each superfamily? Use violin plots for this -> actually it looks bad, don't use it
ggplot(rep_table.m, aes(x = fam, y = distance, fill = fam)) +
  geom_violin(trim = FALSE, scale = "count") +
  labs(title = "Distance Violin Plots", x = "Superfamily", y = "Distance") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

# Question: Do you have other clades of LTR-RTs not present in the full length elements?
# You have to use the TEsorter output from Intact LTR-RTs and TElib to answer this question


# AED score distribution -----
AED_data <- read.table("assembly.all.maker.renamed.gff.AED.txt", header = T) %>%
  rename("unfiltered" = assembly.all.maker.noseq.gff.renamed.gff)
AED_data_filtered <- read.table("assembly.all.maker.renamed.iprscan_quality_filtered.gff.AED.txt", header = T) %>%
  rename("filtered" = assembly.all.maker.noseq.gff_iprscan_quality_filtered.gff)

AED_all <- full_join(AED_data, AED_data_filtered, by = "AED")
plot(AED_data$AED, AED_data$assembly.all.maker.noseq.gff.renamed.gff, type = "l", xlab = "AED score", ylab = "frequency")

AED_data_filtered <- read.table("assembly.all.maker.renamed.gff.AED0.5.txt", header = T)
plot(AED_data$AED, AED_data$assembly.all.maker.noseq.gff.renamed.gff, type = "l", xlab = "AED score", ylab = "frequency")

# plot

AED_all %>%
  pivot_longer(cols = c(filtered, unfiltered),
             names_to = "type", values_to = "cumulative fraction") %>%
  ggplot(aes(x = AED, y = `cumulative fraction`, color = type)) +
  geom_line(size = 0.6) +
  labs(x = "AED", y = "cumulative fraction", color = NULL) +
  theme_minimal() +
  theme(legend.position = "right")


# Min, Max, Median of gene lengths etc. ------
genes <- read.table("gene_lengths.txt")
min(genes)
max(genes)
median(genes$V1)

mrnas <- read.table("mRNA_lengths.txt")
min(mrnas)
max(mrnas)
median(mrnas$V1)

exons <- read.table("exon_lengths.txt")
min(exons)
max(exons)
median(exons$V1)

introns <- read.table("intron_lengths.txt")
min(introns)
max(introns)
median(introns$V1)

exons_per_gene <- read.table("exon_counts.txt")
min(exons_per_gene$V1)
max(exons_per_gene$V1)
median(exons_per_gene$V1)
