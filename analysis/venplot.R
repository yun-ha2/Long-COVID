# =========================================================
# Venn overlap plots for DEGs (portfolio-ready)
# - Input: lists of gene vectors (character)
# - Output: ggvenn + ggVennDiagram versions (+ optional save)
# =========================================================

library(ggplot2)
library(ggvenn)
library(ggVennDiagram)

# -----------------------------
# 1) Define gene lists
# -----------------------------
venn_up_list <- list(
  "M vs. S6" = genes_up_6vs0,
  "S6 vs. S15" = genes_up_15vs6,
  "S6 vs. S30" = genes_up_30vs6,
  "S6 vs. S60" = genes_up_60vs6,
  "S6 vs. S90" = genes_up_90vs6
)

venn_down_list <- list(
  "M vs. S6" = genes_down_6vs0,
  "S6 vs. S15" = genes_down_15vs6,
  "S6 vs. S30" = genes_down_30vs6,
  "S6 vs. S60" = genes_down_60vs6,
  "S6 vs. S90" = genes_down_90vs6
)

# -----------------------------
# 2) Basic sanity checks
# -----------------------------
stopifnot(all(vapply(venn_up_list, is.character, logical(1))))
stopifnot(all(vapply(venn_down_list, is.character, logical(1))))

# Optional: remove NA + enforce unique
clean_gene_sets <- function(x) {
  lapply(x, function(v) unique(na.omit(v)))
}
venn_up_list <- clean_gene_sets(venn_up_list)
venn_down_list <- clean_gene_sets(venn_down_list)

# -----------------------------
# 3) Plot helpers
# -----------------------------
plot_ggvenn <- function(gene_list, title, fill_colors) {
  ggvenn(
    gene_list,
    fill_color = fill_colors,
    stroke_size = 1,
    set_name_size = 10,
    text_size = 10
  ) +
    ggtitle(title) +
    theme(
      plot.title = element_text(size = 14, face = "bold", hjust = 0.5)
    )
}

plot_ggVennDiagram <- function(gene_list, title, low, high) {
  ggVennDiagram(gene_list, label_alpha = 0) +
    scale_fill_gradient(low = low, high = high) +
    theme_void() +
    theme(
      legend.position = "none",
      plot.title = element_text(size = 16, face = "bold", hjust = 0.5)
    ) +
    ggtitle(title)
}

# -----------------------------
# 4) Create plots
# -----------------------------
p_up_basic <- plot_ggvenn(
  venn_up_list,
  title = "Up-regulated DEGs Overlap",
  fill_colors = c("#FFCFBC", "#E74C3C")
)

p_down_basic <- plot_ggvenn(
  venn_down_list,
  title = "Down-regulated DEGs Overlap",
  fill_colors = c("#ADD8E6", "#2874A6")
)

p_up_grad <- plot_ggVennDiagram(
  venn_up_list,
  title = "Up-regulated DEGs Overlap",
  low = "#FDEDEC",
  high = "#E74C3C"
)

p_down_grad <- plot_ggVennDiagram(
  venn_down_list,
  title = "Down-regulated DEGs Overlap",
  low = "#EAF2F8",
  high = "#2874A6"
)

# Show in RStudio
p_up_basic
p_down_basic
p_up_grad
p_down_grad

# -----------------------------
# 5) (Optional) Save figures
# -----------------------------
# ggsave("venn_up_basic.png",   p_up_basic,  width = 8, height = 6, dpi = 300)
# ggsave("venn_down_basic.png", p_down_basic,width = 8, height = 6, dpi = 300)
# ggsave("venn_up_grad.png",    p_up_grad,   width = 8, height = 6, dpi = 300)
# ggsave("venn_down_grad.png",  p_down_grad, width = 8, height = 6, dpi = 300)
