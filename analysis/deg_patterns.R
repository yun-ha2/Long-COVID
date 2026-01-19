# ============================================================
# Temporal expression pattern analysis of DEGs
# (DESeq2 + DEGreport)
# ============================================================

library(DESeq2)
library(DEGreport)
library(dplyr)
library(ggplot2)

# ------------------------------------------------------------
# Inputs
#   dds          : DESeqDataSet
#   deg_genes    : vector of DEG gene IDs
#   dpi          : numeric vector of DPI values
# ------------------------------------------------------------

# rlog transformation
rld <- rlog(dds, blind = FALSE)
expr <- assay(rld)

# subset to DEGs
expr_deg <- expr[deg_genes, ]

# design matrix
design <- data.frame(
  sample = colnames(expr_deg),
  DPI = dpi,
  row.names = colnames(expr_deg)
)

# DEG temporal pattern clustering
deg_res <- degPatterns(expr_deg, design, time = "DPI")

# visualization
plot(deg_res$dend)
plot(deg_res$plot)

# extract genes by cluster
clusters <- list(
  group1  = deg_res$df %>% filter(cluster == 1),
  group2  = deg_res$df %>% filter(cluster == 2),
  group3  = deg_res$df %>% filter(cluster == 3),
  group6  = deg_res$df %>% filter(cluster == 6),
  group7  = deg_res$df %>% filter(cluster == 7),
  group9  = deg_res$df %>% filter(cluster == 9),
  group10 = deg_res$df %>% filter(cluster == 10),
  group12 = deg_res$df %>% filter(cluster == 12),
  group13 = deg_res$df %>% filter(cluster == 13),
  group15 = deg_res$df %>% filter(cluster == 15)
)