#!/usr/bin/env Rscript
# ============================================================
# WGCNA: Weighted Gene Co-expression Network Analysis
# - Input: TPM_data.csv (genes x samples TPM matrix)
# - Output: module detection + module-trait associations + hub-gene metrics
# ============================================================

suppressPackageStartupMessages({
  library(WGCNA)
  library(tidyverse)
  library(ggplot2)
  library(CorLevelPlot)
})

allowWGCNAThreads()

# -----------------------------
# Config
# -----------------------------
expr_file <- "TPM_data.csv"   # genes x samples TPM
outdir <- "results/wgcna"
dir.create(outdir, recursive = TRUE, showWarnings = FALSE)

# Experiment design
dpi_levels <- c(0, 6, 15, 30, 60, 90)
replicates_per_timepoint <- 3

# WGCNA params
network_type <- "signed"
tom_type <- "signed"
merge_cut_height <- 0.25
max_block_size <- 13000
soft_power <- 16            # set after inspecting pickSoftThreshold()
random_seed <- 777

# -----------------------------
# 1) Load & preprocess TPM
# -----------------------------
expr <- read.csv(expr_file, row.names = 1, check.names = FALSE)

# Drop genes with all-zero expression
expr <- expr[rowSums(expr) > 0, ]

# log2(TPM + 1)
expr <- log2(expr + 1)

# WGCNA expects samples x genes
datExpr <- t(expr)

# Save basic dimensions
writeLines(
  c(
    paste0("Samples: ", nrow(datExpr)),
    paste0("Genes: ", ncol(datExpr))
  ),
  file.path(outdir, "input_dimensions.txt")
)

# -----------------------------
# 2) Sample QC (PCA)
# -----------------------------
pca <- prcomp(datExpr, scale. = TRUE)
pca_df <- as.data.frame(pca$x) %>%
  rownames_to_column("Sample")

p <- ggplot(pca_df, aes(PC1, PC2)) +
  geom_point(size = 3) +
  theme_classic() +
  labs(title = "PCA (log2(TPM+1))", x = "PC1", y = "PC2")

ggsave(file.path(outdir, "pca_samples.png"), p, width = 7, height = 5, dpi = 300)

# -----------------------------
# 3) Build metadata (DPI)
# -----------------------------
meta_df <- data.frame(
  Sample = rownames(datExpr),
  DPI = factor(
    rep(dpi_levels, each = replicates_per_timepoint),
    levels = dpi_levels
  )
)
rownames(meta_df) <- meta_df$Sample

# Sanity check
stopifnot(nrow(meta_df) == nrow(datExpr))

# Trait example: DPI 0 vs rest (binary)
traits <- meta_df %>%
  transmute(DPI_0_vs_rest = ifelse(DPI == "0", 1, 0))
rownames(traits) <- rownames(meta_df)

# -----------------------------
# 4) Soft-threshold selection
# -----------------------------
powers <- c(1:10, seq(12, 50, 2))

sft <- pickSoftThreshold(
  datExpr,
  powerVector = powers,
  networkType = network_type,
  verbose = 3
)

sft_df <- sft$fitIndices %>%
  as.data.frame()

p_sft1 <- ggplot(sft_df, aes(Power, SFT.R.sq)) +
  geom_point() +
  geom_text(aes(label = Power), nudge_y = 0.05, size = 3) +
  geom_hline(yintercept = 0.8, linetype = "dashed", color = "red") +
  theme_classic() +
  labs(x = "Soft-threshold power", y = "Scale-free topology fit (signed R^2)")

p_sft2 <- ggplot(sft_df, aes(Power, mean.k.)) +
  geom_point() +
  geom_text(aes(label = Power), nudge_y = 0.05, size = 3) +
  theme_classic() +
  labs(x = "Soft-threshold power", y = "Mean connectivity")

ggsave(file.path(outdir, "soft_threshold_fit.png"), p_sft1, width = 7, height = 5, dpi = 300)
ggsave(file.path(outdir, "soft_threshold_connectivity.png"), p_sft2, width = 7, height = 5, dpi = 300)

write.csv(sft_df, file.path(outdir, "soft_threshold_fit_indices.csv"), row.names = FALSE)

# -----------------------------
# 5) Network construction + module detection
# -----------------------------
set.seed(random_seed)

net <- blockwiseModules(
  datExpr,
  power = soft_power,
  TOMType = tom_type,
  networkType = network_type,
  maxBlockSize = max_block_size,
  mergeCutHeight = merge_cut_height,
  numericLabels = FALSE,
  randomSeed = random_seed,
  verbose = 3
)

moduleColors <- net$colors
moduleEigengenes <- net$MEs

# Save module sizes
module_sizes <- sort(table(moduleColors), decreasing = TRUE)
write.csv(
  data.frame(Module = names(module_sizes), N_genes = as.integer(module_sizes)),
  file.path(outdir, "module_sizes.csv"),
  row.names = FALSE
)

# -----------------------------
# 6) Module???trait associations
# -----------------------------
moduleTraitCor <- cor(moduleEigengenes, traits, use = "p")
moduleTraitPval <- corPvalueStudent(moduleTraitCor, nSamples = nrow(datExpr))

write.csv(moduleTraitCor, file.path(outdir, "module_trait_cor.csv"))
write.csv(moduleTraitPval, file.path(outdir, "module_trait_pval.csv"))

# Heatmap-style correlation plot (module eigengenes vs traits)
png(file.path(outdir, "module_trait_corlevelplot.png"), width = 1600, height = 900, res = 180)
CorLevelPlot(
  cbind(moduleEigengenes, traits),
  x = colnames(traits),
  y = colnames(moduleEigengenes),
  col = c("blue", "white", "red")
)
dev.off()

# -----------------------------
# 7) Intramodular metrics (hub gene candidates)
# -----------------------------
# Module Membership (MM): cor(gene expression, module eigengene)
MM <- cor(moduleEigengenes, datExpr, use = "p")
MM_pval <- corPvalueStudent(MM, nSamples = nrow(datExpr))

# Gene Significance (GS): cor(gene expression, trait)
GS <- cor(datExpr, traits$DPI_0_vs_rest, use = "p")
GS_pval <- corPvalueStudent(GS, nSamples = nrow(datExpr))

# Compile per-gene table
gene_table <- tibble(
  Gene = colnames(datExpr),
  Module = moduleColors,
  GS = as.numeric(GS),
  GS_pval = as.numeric(GS_pval)
)

# Add MM columns (one per module)
MM_df <- as.data.frame(t(MM))
colnames(MM_df) <- paste0("MM_", colnames(moduleEigengenes))
MM_p_df <- as.data.frame(t(MM_pval))
colnames(MM_p_df) <- paste0("MMp_", colnames(moduleEigengenes))

gene_table <- bind_cols(gene_table, MM_df, MM_p_df)

write.csv(gene_table, file.path(outdir, "gene_module_mm_gs_table.csv"), row.names = FALSE)

# Example: export genes from a module (turquoise)
target_module <- "turquoise"
target_genes <- gene_table %>%
  filter(Module == target_module) %>%
  arrange(desc(abs(.data[[paste0("MM_ME", target_module)]])), desc(abs(GS)))

write.csv(target_genes, file.path(outdir, paste0("genes_", target_module, ".csv")), row.names = FALSE)

