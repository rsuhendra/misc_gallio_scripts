library(rstudioapi)  
library(tximport)
library(AnnotationDbi)
library(org.Dm.eg.db)
library(readr)
library(tidyr) 


dir = dirname(getActiveDocumentContext()$path)
setwd(dir) 

# File takes all filenames in FS and combines them for further analysis

# Insert file names here as such
fs = c("49B06C","49B06D","49B06I","19428F","19428I","19428J",
       "22C06-3_S1","22C06-4_S2","22C06-5_S3","22C06-6_S4",
       "PF1_S5","PF2_S6","PF3_S7","PF4_S8","dm502","dm503","dm506")
files <- file.path(dir, paste0(fs, ".genes.results"))

# characterizes cells based on what they are
names(files) <- c(paste0('slow', 1:3), paste0('fast', 1:3), paste0('22c06_', 1:4),
                  paste0('PF', 1:4), paste0('AC', 1:3))

# Combines the rsem files into one big dataframe
txi.rsem <- tximport(files, type = "rsem", txIn = FALSE, txOut = FALSE) # genes
head(txi.rsem$abundance)    # visualize the dataframe created
df <- as.data.frame(txi.rsem$abundance) # can also get counts, but abundance is normalized
df <- cbind(ID = row.names(df), df)    #change name
row.names(df) <- NULL

# Get Genename and Symbol from Flybase
df$name =   mapIds(org.Dm.eg.db,
                    keys=df$ID, 
                    column="GENENAME",
                    keytype="FLYBASE",
                    multiVals="first")
df$symbol <- mapIds(org.Dm.eg.db, 
                     keys=df$ID, 
                     column="SYMBOL", 
                     keytype="FLYBASE",
                     multiVals="first")

# Take in gene summary and drop all terms except ID and Summary
df2 <- read.delim("best_gene_summary_fb_2023_04.tsv",skip = 8, sep="\t")
colnames(df2)[1] <- "ID"
df2 <- df2[, -c(2,3)] 


# merge the dataframes and keep only GeneIds that were originally in there. 
merged_df <- merge(df, df2, by = "ID", all = TRUE)
merged_df <- merged_df[merged_df$ID %in% df$ID, ]


# Add GO terms
test <- mapIds(org.Dm.eg.db, 
               keys=merged_df$ID, 
               column="GOALL", 
               keytype="FLYBASE",
               multiVals="CharacterList")

for (i in 1:length(test)) {
  merged_df$GO[i] <- paste(test[[i]], collapse=';')
}

# Write to csv file
write.csv(merged_df,file='all_cells_tpm.csv')

#####

