# =========================================================
# GO Enrichment Analysis Pipeline (Portfolio-ready)
# - Input  : DEG list (gene symbols)
# - Output : GO result table + barplot
# =========================================================

library(tidyverse)
library(clusterProfiler)
library(org.Mm.eg.db)
library(ggplot2)

# ---------------------------------------------------------
# 1) Load DEG list
# ---------------------------------------------------------
load_gene_list <- function(path, gene_col = 1) {
  df <- read.csv(path, stringsAsFactors = FALSE)
  genes <- df[[gene_col]]
  unique(na.omit(genes))
}

# ---------------------------------------------------------
# 2) Run GO enrichment
# ---------------------------------------------------------
run_go_enrichment <- function(
    genes,
    ont = "BP",
    organism_db = org.Mm.eg.db,
    keytype = "SYMBOL",
    p_cutoff = 0.05,
    q_cutoff = 0.05
) {
  enrichGO(
    gene          = genes,
    OrgDb         = organism_db,
    keyType       = keytype,
    ont           = ont,
    pAdjustMethod = "BH",
    pvalueCutoff  = p_cutoff,
    qvalueCutoff  = q_cutoff,
    readable      = TRUE
  )@result
}

# ---------------------------------------------------------
# 3) Filter GO terms of interest
# ---------------------------------------------------------
filter_go_terms <- function(go_result, terms) {
  go_result %>%
    filter(Description %in% terms) %>%
    mutate(Description = stringr::str_to_title(Description))
}

# ---------------------------------------------------------
# 4) Prepare data for plotting
# ---------------------------------------------------------
prepare_go_plot_df <- function(go_df) {
  go_df %>%
    mutate(
      GeneRatio_num = sapply(
        strsplit(GeneRatio, "/"),
        function(x) as.numeric(x[1]) / as.numeric(x[2])
      ),
      logP = -log10(p.adjust)
    ) %>%
    arrange(logP) %>%
    mutate(Description = factor(Description, levels = Description))
}

# ---------------------------------------------------------
# 5) GO barplot function
# ---------------------------------------------------------
plot_go_bar <- function(
    plot_df,
    low_color,
    high_color,
    title = NULL
) {
  gmin <- min(plot_df$GeneRatio_num, na.rm = TRUE)
  gmax <- max(plot_df$GeneRatio_num, na.rm = TRUE)
  
  ggplot(plot_df, aes(x = logP, y = Description, fill = GeneRatio_num)) +
    geom_col(width = 0.85, color = "black") +
    scale_fill_gradient(
      low = low_color,
      high = high_color,
      limits = c(gmin, gmax),
      name = "GeneRatio",
      guide = guide_colorbar(
        title.position = "top",
        title.hjust = 0.5,
        barwidth = 8,
        barheight = 0.6
      )
    ) +
    theme_bw() +
    theme(
      panel.grid = element_blank(),
      axis.title.y = element_blank(),
      axis.text.y  = element_text(size = 12, color = "black"),
      axis.title.x = element_text(size = 13, face = "bold"),
      axis.text.x  = element_text(size = 12),
      legend.position = "top",
      plot.title = element_text(size = 14, face = "bold", hjust = 0.5)
    ) +
    labs(x = "-log10(adjusted P-value)", title = title)
}


# -----------------------------
# Input files
# -----------------------------
up_path   <- "degs_up.csv"
down_path <- "degs_down.csv"

genes_up   <- load_gene_list(up_path)
genes_down <- load_gene_list(down_path)

# -----------------------------
# Run GO
# -----------------------------
go_up   <- run_go_enrichment(genes_up, ont = "BP")
go_down <- run_go_enrichment(genes_down, ont = "BP")

# -----------------------------
# Select terms (example)
# -----------------------------
immune_terms <- c(
  "regulation of innate immune response",
  "response to virus",
  "cytokine activity",
  "chemokine activity"
)

neural_terms <- c(
  "neuropeptide signaling pathway",
  "neurotransmitter receptor activity",
  "neuropeptide activity"
)

go_up_sel   <- filter_go_terms(go_up, immune_terms)
go_down_sel <- filter_go_terms(go_down, neural_terms)

# -----------------------------
# Plot
# -----------------------------
p_up <- plot_go_bar(
  prepare_go_plot_df(go_up_sel),
  low_color  = "#FDE5C2",
  high_color = "#D52B1E",
  title = "GO Enrichment of Up-regulated DEGs"
)

p_down <- plot_go_bar(
  prepare_go_plot_df(go_down_sel),
  low_color  = "#DBE9FF",
  high_color = "#3A8DD0",
  title = "GO Enrichment of Down-regulated DEGs"
)

p_up
p_down
