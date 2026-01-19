library(tidyverse)
library(igraph)
library(ggraph)

# =========================================================
# Build GO-term ¡ê gene network centered on a target gene
# =========================================================
build_go_network <- function(
    go_result_df,
    target_gene,
    highlight_genes = NULL,      # optional: restrict gene nodes to this set
    padj_cutoff = 0.05,
    term_col = "Description",
    geneid_col = "geneID",
    sep = "/",
    make_upper_terms = TRUE
) {
  stopifnot(all(c(term_col, geneid_col, "p.adjust") %in% colnames(go_result_df)))
  
  df <- go_result_df %>%
    filter(!is.na(p.adjust), p.adjust < padj_cutoff) %>%
    mutate(
      term = .data[[term_col]],
      genes_raw = .data[[geneid_col]]
    )
  
  # keep only terms that contain target_gene in geneID list
  df_target <- df %>%
    filter(str_detect(genes_raw, paste0("(^|", sep, ")", fixed(target_gene), "(", sep, "|$)")) |
             str_detect(genes_raw, fixed(target_gene)))
  
  if (nrow(df_target) == 0) {
    stop("No GO terms contain target_gene under the given filters.")
  }
  
  if (make_upper_terms) {
    df_target <- df_target %>% mutate(term = toupper(term))
  }
  
  # term nodes
  term_nodes <- df_target %>%
    distinct(term) %>%
    transmute(name = term, type = "Term")
  
  # edges: target_gene -> term
  edges_target_term <- df_target %>%
    transmute(from = target_gene, to = term)
  
  # edges: term -> other genes (excluding target)
  term_gene_edges <- df_target %>%
    mutate(gene = str_split(genes_raw, sep)) %>%
    unnest(gene) %>%
    mutate(gene = str_trim(gene)) %>%
    filter(gene != target_gene) %>%
    transmute(from = term, to = gene)
  
  # optional: restrict to highlight genes
  if (!is.null(highlight_genes)) {
    hl <- unique(na.omit(highlight_genes))
    term_gene_edges <- term_gene_edges %>% filter(to %in% hl)
  }
  
  edges <- bind_rows(edges_target_term, term_gene_edges) %>% distinct()
  
  # gene nodes (including target)
  gene_nodes <- tibble(name = unique(c(target_gene, term_gene_edges$to))) %>%
    mutate(type = ifelse(name == target_gene, "TargetGene", "Gene"))
  
  nodes <- bind_rows(
    gene_nodes,
    term_nodes
  ) %>% distinct(name, .keep_all = TRUE)
  
  list(nodes = nodes, edges = edges)
}

# =========================================================
# Plot the network (portfolio-ready)
# =========================================================
plot_go_network <- function(
    nodes, edges,
    layout = "graphopt",
    title = NULL
) {
  g <- graph_from_data_frame(edges, vertices = nodes, directed = FALSE)
  
  ggraph(g, layout = layout) +
    geom_edge_link(alpha = 0.7, color = "gray70") +
    geom_node_point(
      aes(shape = type),
      size = case_when(
        nodes$type == "TargetGene" ~ 8,
        nodes$type == "Term"       ~ 6.5,
        TRUE                       ~ 5
      )
    ) +
    geom_node_text(
      aes(label = name,
          fontface = ifelse(type %in% c("TargetGene", "Gene"), "bold", "plain")),
      size = case_when(
        nodes$type == "TargetGene" ~ 6,
        nodes$type == "Term"       ~ 3.8,
        TRUE                       ~ 4.2
      ),
      repel = TRUE,
      segment.color = NA
    ) +
    scale_shape_manual(values = c("TargetGene" = 16, "Term" = 15, "Gene" = 16)) +
    theme_void() +
    theme(
      legend.position = "none",
      plot.title = element_text(size = 14, face = "bold", hjust = 0.5)
    ) +
    ggtitle(title %||% "GO-term ¡ê gene network")
}



go_up_df   <- go_up_6_0@result   %>% mutate(Direction = "Up")
go_down_df <- go_down_6_0@result %>% mutate(Direction = "Down")

go_combined <- bind_rows(go_up_df, go_down_df)




target_gene <- "GeneH"   
net <- build_go_network(
  go_result_df = go_combined,
  target_gene = target_gene,
  highlight_genes = NULL,  
  padj_cutoff = 0.05,
  make_upper_terms = TRUE
)

p <- plot_go_network(
  nodes = net$nodes,
  edges = net$edges,
  layout = "graphopt",
  title = paste0("GO network centered on ", target_gene)
)

p
