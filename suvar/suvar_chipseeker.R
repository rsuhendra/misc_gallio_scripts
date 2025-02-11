library(rstudioapi)  
library(ChIPseeker)
library(clusterProfiler)
library(org.Dm.eg.db)
library(TxDb.Dmelanogaster.UCSC.dm6.ensGene)
library(IRanges)
library(GenomicRanges)
library(ggplot2)
library(dplyr)



# Set working directory to file 
dir = dirname(getActiveDocumentContext()$path)
setwd(dir) 

# Preload data
txdb <- TxDb.Dmelanogaster.UCSC.dm6.ensGene
peaks <- readPeakFile('suvar_combined_peaks.filtered.bed')

# Filter our small chromosomes(?)
chroms_to_keep <- c("2L", "2R", "3L", "3R", "X", "4")
peaks <- keepSeqlevels(peaks, chroms_to_keep, pruning.mode = "coarse")
# Change names to match with txdb
seqlevels(peaks) <- paste0("chr", seqlevels(peaks))

# Annotate the peaks
peakAnno <- annotatePeak(peaks, tssRegion=c(-1000, 1000), TxDb=txdb, annoDb="org.Dm.eg.db")
peakAnnoDf <- as.data.frame(peakAnno)
# write.csv(peakAnnoDf, "peakAnno.csv")

# Plots
covplot(peaks, weightCol="V5")
plotAnnoPie(peakAnno)

# Compare to Bill's RNA seq data
peakAnnoRedux <- subset(peakAnnoDf, annotation == "Promoter")
rnaseq_genes <- read.csv('500_genes.csv', header = FALSE, col.names = c('gene_names') )
rnaseq_genes <- rnaseq_genes %>% mutate(genes = sub("_.*", "", gene_names))
match_genes <- intersect(unique(peakAnnoRedux$geneId), rnaseq_genes$genes)

rnaseq_genes$match <- ifelse(rnaseq_genes$genes %in% match_genes, 1, 0)
rnaseq_genes$match <- factor(rnaseq_genes$match)
rnaseq_genes$rank <- seq_len(nrow(rnaseq_genes))
write.csv(rnaseq_genes, "peaksInRna.csv", row.names = FALSE)

# Extra stuff
rnaseq_genesx <- rnaseq_genes[1:100,]
rnaseq_genesx <- subset(rnaseq_genesx, rnaseq_genesx$match == 1)
write.csv(rnaseq_genesx, "peaksInRnaTopMatches.csv", row.names = FALSE)


# Ranked plot
ggplot(rnaseq_genes, aes(x = 1, y = rank, fill = match)) +
  geom_tile(color = "black", size = 0.001) +  # Black border for each bar
  scale_y_reverse() +  # Reverse so Rank 1 is at the top
  scale_fill_manual(values = c("gray80", "blue")) +  # Color scheme
  labs(title = "Rank Plot", x = "", y = "rank", fill = "match") +
  theme_minimal() +
  theme(axis.text.x = element_blank(),  # Remove x-axis text
        axis.ticks.x = element_blank(),
        panel.grid = element_blank())  # Remove grid lines


rnaseq_genes$rank <- rnaseq_genes$rank/nrow(rnaseq_genes)
model <- glm(match ~ rank, data = rnaseq_genes, family = binomial)
summary(model)

# Predicting for sanity check
# print(predict(model, newdata = data.frame(rank = 0), type = "response"))


# GO cluster analysis
# entrezids <- peakAnnoDf$ENTREZID %>% unique()
entrezids <- rnaseq_genesx$genes

ego <- enrichGO(gene = entrezids, 
                keyType = "FLYBASE", 
                OrgDb = org.Dm.eg.db, 
                ont = "BP", 
                pAdjustMethod = "BH", 
                qvalueCutoff = 0.05, 
                readable = TRUE)

dotplot(ego, font.size = 8, title = 'Suvar', label_format = 50, showCategory = 20)

# Count the number of significant terms
significant_go <- subset(ego@result, p.adjust < 0.05)
num_significant <- nrow(significant_go)
print(num_significant)
