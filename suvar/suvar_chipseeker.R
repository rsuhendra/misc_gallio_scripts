library(rstudioapi)  
library(ChIPseeker)
library(clusterProfiler)
library(org.Dm.eg.db)
library(TxDb.Dmelanogaster.UCSC.dm6.ensGene)
library(IRanges)
library(GenomicRanges)


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
write.csv(peakAnnoDf, "peakAnno.csv")

# # Get unique gene Ids
# uniqueIds <- sort(table(peakAnnoDf$geneId))

# Plots
covplot(peaks, weightCol="V5")
plotAnnoPie(peakAnno)

# GO cluster analysis
entrezids <- peakAnnoDf$ENTREZID %>% unique()
ego <- enrichGO(gene = entrezids, 
                keyType = "ENTREZID", 
                OrgDb = org.Dm.eg.db, 
                ont = "BP", 
                pAdjustMethod = "BH", 
                qvalueCutoff = 0.05, 
                readable = TRUE)

dotplot(ego, font.size = 8, title = 'Suvar', label_format = 50, showCategory = 10)

# Count the number of significant terms
significant_go <- subset(ego@result, p.adjust < 0.05)
num_significant <- nrow(significant_go)
print(num_significant)
