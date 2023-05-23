library(phyloseq)
library(ape)
library(ggplot2)
library(RColorBrewer)
library(viridis)

##########################################
#######ALPHA_DIVERSITYV###################
#Creation de l'objet Lineage####################
lineage <- read.csv2("Lineage_DNA_RNA_hosts.csv", header = TRUE)
taxa <- lineage
rownames(taxa) <- taxa$name
taxa <- taxa[-1]
taxa <- as.matrix(taxa)
TAX <- tax_table(taxa)

#Création de l'objet Sample######################
metadata <- read.csv2("Metadata.csv", header = TRUE)
rownames(metadata) <- metadata$name
Sample <- sample_data(metadata)

#Création de la matrice OTU#####################
tax_mat <- read.csv2("tax_mat.csv", header = TRUE)
rownames(tax_mat) <- tax_mat$X
tax_mat <- tax_mat[-1]
tax_mat[is.na(tax_mat)] <- 0
OTU <- otu_table(tax_mat, taxa_are_rows = TRUE)

#création de l'objet phyloseq##################
physeq <- phyloseq(OTU, TAX, Sample)
random_tree <- rtree(ntaxa(physeq), rooted = TRUE, tip.label = taxa_names(physeq))
physeq <- phyloseq(OTU, TAX, Sample, random_tree)

#Enlever les OTU qui n'ont pas de Phylum et d'host
physeq <- subset_taxa(physeq, Phylum != "")
physeq <- subset_taxa(physeq, Host != "")
physeq <- subset_taxa(physeq, Host != "NA")

#plot(random_tree)

#DIVERSITY TOUT VIRUS###
p <- plot_richness(physeq, measures = c("Observed", "chao", "Shannon", "Simpson"), color = "Group", x = "Group")
p + theme_bw() + geom_boxplot() + geom_point(size = 3, alpha = 0.1) + theme(axis.text.x = element_blank()) + scale_color_viridis_d()

rich <- estimate_richness(physeq, measures = c("Observed", "chao", "Shannon", "Simpson"))
pairwise.wilcox.test(rich$Simpson, sample_data(physeq)$Group, p.adjust.methods = "bonferroni")


#DIVERSITY VIRUS VERTEBRES###
physeq.ver <- subset_taxa(physeq, Host == "Vertebrates")
p <- plot_richness(physeq.ver, measures = c("Observed", "chao", "Shannon", "Simpson"), color = "Group", x = "Group")
p + theme_bw() + geom_boxplot() + geom_point(size = 3, alpha = 0.1) + theme(axis.text.x = element_blank()) + scale_color_viridis_d()

ggplot_build(p)$plot$data -> gp
write.csv2(gp, "dataFSuppANalysisFig1B.csv")

rich <- estimate_richness(physeq.ver, measures = c("Observed", "chao", "Shannon", "Simpson"))
pairwise.wilcox.test(rich$Simpson, sample_data(physeq.ver)$Group, p.adjust.methods = "bonferroni")


#DIVERSITY VIRUS PHAGES###
physeq.phages <- subset_taxa(physeq, Host == "Bacteria and Archea")
p <- plot_richness(physeq.phages, measures = ("Observed", "chao", "Shannon", "Simpson"), color = "Group", x = "Group")
p + theme_bw() + geom_boxplot() + geom_point(size = 3, alpha = 0.1) + theme(axis.text.x = element_blank()) + scale_color_viridis_d()

rich <- estimate_richness(physeq.phages, measures = c("Observed", "chao", "Shannon", "Simpson"))
pairwise.wilcox.test(rich$Simpson, sample_data(physeq.ver)$Group, p.adjust.methods = "bonferroni")

                     