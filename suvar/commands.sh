# Commands run for CHIPseq 

# Build Bowtie2 database
bowtie2-build dmel-all-chromosome-r6.61.fasta dmel_index

# Align reads using Bowtie2
bowtie2 -p 40 --local --very-sensitive-local \
-x ../index/dmel_index \
-U ../fastq/SRR870224.fastq.gz \
-S SRR870224_unsorted.sam

# Convert Sam file to Bam
samtools view -h -S -b -o SRR870227_unsorted.bam SRR870227_unsorted.sam

# Sort bam file
samtools sort SRR870227_unsorted.bam -o SRR870227_sorted.bam

# Filter out unmapped and duplicate reads
sambamba view -h -t 40 -f bam \
-F "[XS] == null and not unmapped and not duplicate" SRR870227_sorted.bam > SRR870227_final.bam

# Peak calling 

# Find peaks using Macs3
macs3 callpeak -t ../align/SRR870226_final.bam \
    -c ../align/SRR870224_final.bam \
    -f BAM -g dm \
    -n suvar1 \
    --outdir ../peaks 2> suvar1_macs3.log

macs3 callpeak -t ../align/SRR870227_final.bam \
    -c ../align/SRR870225_final.bam \
    -f BAM -g dm \
    -n suvar2 \
    --outdir ../peaks 2> suvar2_macs3.log


# Filter out blacklisted regions
bedtools intersect -v -a suvar1_peaks.narrowPeak -b dm6-blacklist.v2.bed > suvar1_peaks.filtered.bed

bedtools intersect -v -a suvar2_peaks.narrowPeak -b dm6-blacklist.v2.bed > suvar2_peaks.filtered.bed


# Combine replicates
bedtools intersect \
-wo -f 0.3 -r \
-a suvar1_peaks.filtered.bed \
-b suvar2_peaks.filtered.bed \
> suvar_combined_peaks.filtered.bed