library(EnhancedVolcano)
library(grid)  

res <- DESeq(dds)

res_6_vs_0 <- results(res, contrast = c("DPI", "6", "0"),alpha = 0.05)

keyvals.colour <- ifelse(
  res_6_vs_0$log2FoldChange < -1 & res_6_vs_0$pvalue < 1e-5, 'royalblue',
  ifelse(
    res_6_vs_0$log2FoldChange > 1 & res_6_vs_0$pvalue < 1e-5, 'red',
    ifelse(
      (res_6_vs_0$log2FoldChange < -1 | res_6_vs_0$log2FoldChange > 1) & res_6_vs_0$pvalue > 1e-5,
      '#228C22',
      'black'
    )
  )
)


names(keyvals.colour)[keyvals.colour == 'royalblue'] <- 'Down regulated'
names(keyvals.colour)[keyvals.colour == 'red'] <- 'Up regulated'
names(keyvals.colour)[keyvals.colour == '#228C22'] <- 'Non-sig'
names(keyvals.colour)[keyvals.colour == 'black'] <- ''




EnhancedVolcano(
  res_6_vs_0,
  lab = rownames(res_6_vs_0),
  title = 'M vs. S6',
  subtitle = '',
  axisLabSize = 25,
  titleLabSize = 25,
  x = 'log2FoldChange',
  y = 'pvalue',
  ylab = expression(-Log[10] * Pvalue),
  legendPosition = 'none',
  colCustom = keyvals.colour,
  legendLabSize = 12,
  pointSize = 2.0,
  labSize = 6.0,
  labFace = 'italic',
  
  drawConnectors = TRUE,               
  typeConnectors = 'open',            
  widthConnectors = 0.6,               
  lengthConnectors = unit(0.02, "npc"),
  arrowheads = FALSE,                  
  max.overlaps = 5                    
)


res_15_vs_6 <- results(res, contrast = c("DPI", "6", "15"),alpha = 0.05)


keyvals.colour <- ifelse(
  res_15_vs_6$log2FoldChange < -1 & res_15_vs_6$pvalue < 1e-5, 'royalblue',
  ifelse(
    res_15_vs_6$log2FoldChange > 1 & res_15_vs_6$pvalue < 1e-5, 'red',
    ifelse(
      (res_15_vs_6$log2FoldChange < -1 | res_15_vs_6$log2FoldChange > 1) & res_15_vs_6$pvalue > 1e-5,
      '#228C22',
      'black'
    )
  )
)

names(keyvals.colour)[keyvals.colour == 'royalblue'] <- 'Down regulated'
names(keyvals.colour)[keyvals.colour == 'red'] <- 'Up regulated'
names(keyvals.colour)[keyvals.colour == '#228C22'] <- 'Non-sig'
names(keyvals.colour)[keyvals.colour == 'black'] <- ''


EnhancedVolcano(
  res_15_vs_6,
  lab = rownames(res_15_vs_6),
  title = 'S6 vs. S15',
  subtitle = '',
  axisLabSize = 15,
  titleLabSize = 25,
  x = 'log2FoldChange',
  y = 'pvalue',
  ylab = expression(-Log[10] * Pvalue),
  legendPosition = 'none',
  colCustom = keyvals.colour,
  legendLabSize = 12,
  pointSize = 2.0,
  labSize = 6.0,
  labFace = 'italic',
  
  drawConnectors = TRUE,              
  typeConnectors = 'open',             
  widthConnectors = 0.6,               
  lengthConnectors = unit(0.02, "npc"),
  arrowheads = FALSE,                 
  max.overlaps = 5                    
)


res_30_vs_6 <- results(res, contrast = c("DPI", "6", "30"),alpha = 0.05)

keyvals.colour <- ifelse(
  res_30_vs_6$log2FoldChange < -1 & res_30_vs_6$pvalue < 1e-5, 'royalblue',
  ifelse(
    res_30_vs_6$log2FoldChange > 1 & res_30_vs_6$pvalue < 1e-5, 'red',
    ifelse(
      (res_30_vs_6$log2FoldChange < -1 | res_30_vs_6$log2FoldChange > 1) & res_30_vs_6$pvalue > 1e-5,
      '#228C22',
      'black'
    )
  )
)

names(keyvals.colour)[keyvals.colour == 'royalblue'] <- 'Down regulated'
names(keyvals.colour)[keyvals.colour == 'red'] <- 'Up regulated'
names(keyvals.colour)[keyvals.colour == '#228C22'] <- 'Non-sig'
names(keyvals.colour)[keyvals.colour == 'black'] <- ''

EnhancedVolcano(
  res_30_vs_6,
  lab = rownames(res_30_vs_6),
  title = 'S6 vs. S30',
  subtitle = '',
  axisLabSize = 15,
  titleLabSize = 25,
  x = 'log2FoldChange',
  y = 'pvalue',
  ylab = expression(-Log[10] * Pvalue),
  legendPosition = 'none',
  colCustom = keyvals.colour,
  legendLabSize = 12,
  pointSize = 2.0,
  labSize = 6.0,
  labFace = 'italic',
  
  drawConnectors = TRUE,              
  typeConnectors = 'open',             
  widthConnectors = 0.6,              
  lengthConnectors = unit(0.02, "npc"),
  arrowheads = FALSE,                  
  max.overlaps = 5                    
)


res_60_vs_6 <- results(res, contrast = c("DPI", "6", "60"),alpha = 0.05)

keyvals.colour <- ifelse(
  res_60_vs_6$log2FoldChange < -1 & res_60_vs_6$pvalue < 1e-5, 'royalblue',
  ifelse(
    res_60_vs_6$log2FoldChange > 1 & res_60_vs_6$pvalue < 1e-5, 'red',
    ifelse(
      (res_60_vs_6$log2FoldChange < -1 | res_60_vs_6$log2FoldChange > 1) & res_60_vs_6$pvalue > 1e-5,
      '#228C22',
      'black'
    )
  )
)

# 선택적으로 이름 붙이기 (범례 이름)
names(keyvals.colour)[keyvals.colour == 'royalblue'] <- 'Down regulated'
names(keyvals.colour)[keyvals.colour == 'red'] <- 'Up regulated'
names(keyvals.colour)[keyvals.colour == '#228C22'] <- 'Non-sig'
names(keyvals.colour)[keyvals.colour == 'black'] <- ''

EnhancedVolcano(
  res_60_vs_6,
  lab = rownames(res_60_vs_6),
  title = 'S6 vs. S60',
  subtitle = '',
  axisLabSize = 15,
  titleLabSize = 25,
  x = 'log2FoldChange',
  y = 'pvalue',
  ylab = expression(-Log[10] * Pvalue),
  legendPosition = 'none',
  colCustom = keyvals.colour,
  legendLabSize = 12,
  pointSize = 2.0,
  labSize = 6.0,
  labFace = 'italic',
  
  drawConnectors = TRUE,              
  typeConnectors = 'open',             
  widthConnectors = 0.6,               
  lengthConnectors = unit(0.02, "npc")
  arrowheads = FALSE,                  
  max.overlaps = 5                   
)


res_90_vs_6 <- results(res, contrast = c("DPI", "6", "90"),alpha = 0.05)


keyvals.colour <- ifelse(
  res_90_vs_6$log2FoldChange < -1 & res_90_vs_6$pvalue < 1e-5, 'royalblue',
  ifelse(
    res_90_vs_6$log2FoldChange > 1 & res_90_vs_6$pvalue < 1e-5, 'red',
    ifelse(
      (res_90_vs_6$log2FoldChange < -1 | res_90_vs_6$log2FoldChange > 1) & res_90_vs_6$pvalue > 1e-5,
      '#228C22',
      'black'
    )
  )
)

names(keyvals.colour)[keyvals.colour == 'royalblue'] <- 'Down regulated'
names(keyvals.colour)[keyvals.colour == 'red'] <- 'Up regulated'
names(keyvals.colour)[keyvals.colour == '#228C22'] <- 'Non-sig'
names(keyvals.colour)[keyvals.colour == 'black'] <- ''


EnhancedVolcano(
  res_90_vs_6,
  lab = rownames(res_90_vs_6),
  title = 'S6 vs. S90',
  subtitle = '',
  axisLabSize = 15,
  titleLabSize = 25,
  x = 'log2FoldChange',
  y = 'pvalue',
  ylab = expression(-Log[10] * Pvalue),
  legendPosition = 'none',
  colCustom = keyvals.colour,
  legendLabSize = 12,
  pointSize = 2.0,
  labSize = 6.0,
  labFace = 'italic',
  
  drawConnectors = TRUE,               
  typeConnectors = 'open',             
  widthConnectors = 0.6,              
  lengthConnectors = unit(0.02, "npc"),
  arrowheads = FALSE,                  
  max.overlaps = 5                    
)
