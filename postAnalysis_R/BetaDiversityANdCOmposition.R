library(phyloseq)
library(ape)
library(ggplot2)
library(RColorBrewer)
library(VennDiagram)
library(RVenn)
library(viridis)

############################################################
##################### BETA DIVERSITY AND COMPOSITION ######################
############################################################

############## CREATE PHYLOSEQ OBJECT ###############
# Lineage object creation ####################
lineage <- read.csv2("Lineage_DNA_RNA_hosts.csv", header = TRUE)
taxa <- lineage
rownames(taxa) <- taxa$name
taxa <- taxa[-1]
taxa <- as.matrix(taxa)
TAX <- tax_table(taxa)

# Sample object creation ######################
metadata <- read.csv2("Metadata.csv", header = TRUE)
rownames(metadata) <- metadata$name
Sample <- sample_data(metadata)

# OTU matrix creation #####################
tpm <- read.csv2("tpmADNARN.csv")
rownames(tpm) <- tpm$Colonne1
tpm <- tpm[-1]
OTU2 <- otu_table(tpm, taxa_are_rows = TRUE)

# Create phyloseq object ##################
physeq2 <- phyloseq(OTU2, TAX, Sample)
random_tree2 <- rtree(ntaxa(physeq2), rooted = TRUE, tip.label = taxa_names(physeq2))
physeq2 <- phyloseq(OTU2, TAX, Sample, random_tree2)

####### FILTER PHYLOSEQ ###########################
# Remove taxa with 0 counts
physeq2 <- filter_taxa(physeq2, function(x) mean(x) > 0, TRUE)
# Filter taxa observed in all samples
physeq2 <- filter_taxa(physeq2, function(x) sum(x) < length(x), TRUE)

# Remove OTUs without Phylum and host information
# physeq2 <- subset_taxa(physeq2, Phylum != "")
# physeq2 <- subset_taxa(physeq2, Host != "")
# physeq2 <- subset_taxa(physeq2, Host != "NA")

# Select Vertebrates
physeq.ver2 <- subset_taxa(physeq2, Host == "Vertebrates")

###### PCoA ##############

# PCoA Unifrac
ordu <- ordinate(physeq2, "PCoA", "unifrac")
p <- plot_ordination(physeq2, ordu, color = "Group")
p + theme_bw() + geom_point(size = 7, alpha = 0.75) + theme(axis.text.x = element_blank()) + scale_color_viridis_d()

# PCoA Bray
ordu <- ordinate(physeq2, "PCoA", "bray")
p <- plot_ordination(physeq2, ordu, color = "Group")
p + theme_bw() + geom_point(size = 7, alpha = 0.75) + theme(axis.text.x = element_blank()) + scale_color_viridis_d()


## PERMANOVA BETADIVERSITY ##
library("vegan")
bray_dist <- phyloseq::distance(physeq2, method = "bray")
Test <- adonis(formula = bray_dist ~ sample_data(physeq2)$Group)

# Pairwise comparison
library("RVAideMemoire")
pairwise.perm.manova(bray_dist, sample_data(physeq)$Group)

## HEATMAP ##
p <- plot_heatmap(physeq, "PcoA", "bray", "Group", taxa.label = "family", taxa.order = "family", low = "#66CCFF", high = "#000033", na.value = "white", sample.order = "Group")
p + facet_grid(~Group, scales = "free_x")

## NETWORK ##
ig <- make_network(physeq2, dist.fun = "bray", max.dist = 0.95)
plot_network(ig, physeq2, color = "Group", line_weight = 0.3, label = NULL)


# ABUNDANCE PLOTS #
# Convert to relative abundance
physeq2 <- subset_taxa(physeq2, Host != "NA")
physeq3 <- transform_sample_counts(physeq2, function(x) x / sum(x))
dfram <- psmelt(physeq3)
ggplot(dfram, aes(x = Number, y = Abundance, fill = Host)) + geom_bar(aes(color = Host, fill = Host), stat = "identity", position = "stack") + theme(axis.text.x = element_text(size = 12, angle = 90, hjust = 0), axis.text.y = element_text(size = 12), axis.title = element_text(size = 16, face = "bold"), legend.text = element_text(size = 20)) -> g
g + scale_x_discrete(limits = c("X7", "X13", "X32", "X34", "X35", "X40", "X1", "X2", "X5", "X20", "X21", "X22", "X23", "X24", "X26", "X27", "X33", "X36", "X37", "X39", "X41", "X3", "X4", "X6", "X8", "X9", "X10", "X11", "X12", "X14", "X15", "X17", "X18", "X19", "X25", "X28", "X29", "X30", "X42", "X43", "X44", "X45", "X51", "X54", "X57", "X63", "X64", "X47", "X49", "X52", "X53", "X55", "X56", "X46", "X48", "X50", "X58", "X59", "X60", "X62")) + ylab("Distribution of viral reads") + xlab("")

physeq.ver3 <- transform_sample_counts(physeq.ver2, function(x) x / sum(x))
dfram_ver <- psmelt(physeq.ver3)
ggplot(dfram_ver, aes(x = Number, y = Abundance, fill = Family)) + geom_bar(aes(color = Host, fill = Family), stat = "identity", position = "stack") + theme(axis.text.x = element_text(size = 9, angle = 280, hjust = 0, colour = "grey50")) -> g
g + scale_x_discrete(limits = c("X7", "X13", "X32", "X34", "X35", "X40", "X1", "X2", "X5", "X20", "X21", "X22", "X23", "X24", "X26", "X27", "X33", "X36", "X37", "X39", "X41", "X3", "X4", "X6", "X8", "X9", "X10", "X11", "X12", "X14", "X15", "X17", "X18", "X19", "X25", "X28", "X29", "X30", "X42", "X43", "X44", "X45", "X51", "X54", "X57", "X63", "X64", "X47", "X49", "X52", "X53", "X55", "X56", "X46", "X48", "X50", "X58", "X59", "X60", "X62")) + ylab("Distribution of viral reads") + xlab("")

## PLOTS OF THE 10 MOST ABUNDANT VERTEBRATE FAMILIES ##
# Note: This requires a phyloseq object without taxonomic tree information
physeq2 <- phyloseq(OTU2, TAX, Sample)
physeq.ver2 <- subset_taxa(physeq2, Host == "Vertebrates")

top10Family <- sort(tapply(taxa_sums(physeq.ver2), tax_table(physeq.ver2)[, "Family"], sum), decreasing = TRUE)[1:11]
GP <- subset_species(physeq.ver2, Family %in% names(top10Family))
get_taxa_unique(GP, "Family")
GP <- subset_taxa(GP, Family != "")
physeq.ver3 <- transform_sample_counts(GP, function(x) x / sum(x))
dfram_ver <- psmelt(physeq.ver3)

ggplot(dfram_ver, aes(x = Number, y = Abundance, fill = Family)) +
  geom_bar(aes(fill = Family), stat = "identity", position = "stack") +
  theme(axis.text.x = element_text(size = 9, angle = 280, hjust = 0)) -> g
g + scale_x_discrete(limits = c("X7", "X13", "X32", "X34", "X35", "X40", "X1", "X2", "X5", "X20", "X21", "X22", "X23", "X24", "X26", "X27", "X33", "X36", "X37", "X39", "X41", "X3", "X4", "X6", "X8", "X9", "X10", "X11", "X12", "X14", "X15", "X17", "X18", "X19", "X25", "X28", "X29", "X30", "X42", "X43", "X44", "X45", "X51", "X54", "X57", "X63", "X64", "X47", "X49", "X52", "X53", "X55", "X56", "X46", "X48", "X50", "X58", "X59", "X60", "X62"))

