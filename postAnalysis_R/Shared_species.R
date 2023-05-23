xlibrary(phyloseq)
library(ape)
library(ggplot2)
library(RColorBrewer)
library(VennDiagram)
library(set)

#############################################
####### SHARED SPECIES #######################

############## CREATING PHYLOSEQ OBJECT ###############
# Creating Lineage object ####################
lineage <- read.csv2("Lineage_DNA_RNA_hosts.csv", header = TRUE)
taxa <- lineage
rownames(taxa) <- taxa$name
taxa <- taxa[-1]
taxa <- as.matrix(taxa)
TAX <- tax_table(taxa)

# Creating Sample object ######################
metadata <- read.csv2("Metadata.csv", header = TRUE)
rownames(metadata) <- metadata$name
Sample <- sample_data(metadata)

# Creating OTU matrix #####################
tpm <- read.csv2("tpmADNARN.csv")
rownames(tpm) <- tpm$Colonne1
tpm <- tpm[-1]
OTU2 <- otu_table(tpm, taxa_are_rows = TRUE)

# Creating phyloseq object ##################
physeq2 <- phyloseq(OTU2, TAX, Sample)
random_tree2 <- rtree(ntaxa(physeq2), rooted = TRUE, tip.label = taxa_names(physeq2))
physeq2 <- phyloseq(OTU2, TAX, Sample, random_tree2)

####### FILTERING PHYLOSEQ OBJECT ###########################
# Removing taxa with 0 counts
physeq2 <- filter_taxa(physeq2, function(x) mean(x) > 0, TRUE)
# Filtering taxa observed in all samples
# physeq2 <- filter_taxa(physeq2, function(x) sum(x) < length(x), TRUE)

# Removing OTUs without Phylum and host information
physeq2 <- subset_taxa(physeq2, Phylum != "")
physeq2 <- subset_taxa(physeq2, Host != "")

# Selecting Vertebrates
physeq.ver2 <- subset_taxa(physeq2, Host == "Vertebrates")

################# CREATING SPECIES LISTS FOR EACH GROUP #########
# Converting object to a dataframe
mphyseq <- psmelt(physeq.ver2)

# Creating lists for Venn diagrams
CamChim <- subset(mphyseq, Group == "CamChim")
CamChim <- subset(CamChim, Abundance > 0)
CamChimsp <- CamChim[, 1]

CamGor <- subset(mphyseq, Group == "CamGor")
CamGor <- subset(CamGor, Abundance > 0)
CamGorp <- CamGor[, 1]

CamHum <- subset(mphyseq, Group == "CamHum")
CamHum <- subset(CamHum, Abundance > 0)
CamHumsp <- CamHum[, 1]

x <- list(
  "CamChim" = CamChimsp,
  "CamGor" = CamGorp,
  "CamHum" = CamHumsp
)

ZooChim <- subset(mphyseq, Group == "ZooChim")
ZooChim <- subset(ZooChim, Abundance > 0)
ZooChimsp <- ZooChim[, 1]

ZooGor <- subset(mphyseq, Group == "ZooGor")
ZooGor <- subset(ZooGor, Abundance > 0)
ZooGorp <- ZooGor[, 1]

ZooHum<-subset(mphyseq, Group=="ZooHum")
ZooHum<-subset(ZooHum, Abundance>0)
ZooHumsp<-ZooHum[,1]

y <- list(
  "ZooChim" = ZooChimsp, 
  "ZooGor" = ZooGorp, 
  "ZooHum" = ZooHumsp)

############### CREATING VENN DIAGRAMS #####################

# Function to display Venn diagrams
display_venn <- function(x, ...) {
  library(VennDiagram)
  grid.newpage()
  venn_object <- venn.diagram(x, filename = NULL, ...)
  grid.draw(venn_object)
}

# Creating Venn diagrams

display_venn(x, fill = c("#F8766D", "#B79F00", "#00BA38"), cat.fontface = "bold")

display_venn(y, fill = c("#00BFC4", "#619CFF", "#F564E3"), cat.fontface = "bold")

################## OPERATIONS ON VENN DIAGRAMS ############
# Getting the intersections

X <- Venn(x)
overlap(X)

Y <- Venn(y)
overlap(Y)

overlap(X, c("CamChim", "CamHum"))

                  