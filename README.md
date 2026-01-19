# Long-COVID

Long COVID refers to the persistence of neurological and cognitive symptoms after SARS-CoV-2 infection.  

To investigate transcriptional changes underlying these long-term effects, RNA-seq analysis was performed on brain tissues from a SARS-CoV-2 mouse model.
<p align="center">
  <img src="figures/figure1.png" width="300">
</p>

---

## Background

### Long COVID

- Long COVID is frequently accompanied by persistent neurological symptoms, including cognitive impairment, fatigue, and sleep disturbances, suggesting long-lasting disruption of neural circuits after SARS-CoV-2 infection.
- Although neuroinflammation and viral neuroinvasion have been implicated, these mechanisms do not fully explain the specificity and persistence of neurological sequelae.
- Given the central role of hypothalamic neuropeptide signaling in regulating arousal, neuronal survival, and homeostasis, we hypothesized that SARS-CoV-2 selectively disrupts this regulatory system, leading to sustained cortical neuronal dysfunction.
- To characterize SARS-CoV-2–induced neurological alterations, whole-brain samples from infected mouse models were collected across multiple time points (DPI 0, 6, 15, 30, 60, and 90). Bulk RNA-seq was used to profile time-dependent transcriptional changes, with particular emphasis on early responses at DPI 6.

---

## RNA-seq Analysis Overview

### NGS Pipeline 
This repository includes a Snakemake-based RNA-seq preprocessing pipeline that performs quality control, optional trimming, genome alignment, and gene-level quantification.  
Pipeline behavior is configured through `config/samples.tsv` and `config/config.yaml`.

#### Samples Definition (config/samples.tsv)
Only three columns are required:
```tsv
sample	fq1	fq2
0-1	0-1_1.fq.gz	0-1_2.fq.gz
0-2	0-2_1.fq.gz	0-2_2.fq.gz
```
#### Configuration: tool selection (config/config.yaml)
Tool selection can be changed without modifying the workflow code:
```text
trimmer: "none"             # none | trim_galore | trimmomatic
aligner: "hisat2"           # hisat2 | star
quantifier: "featurecounts" # featurecounts | htseq
```

#### Execution

```bash
snakemake --use-conda -j 32
```

## Results


### Gene Pattern Analysis

To identify candidate genes associated with temporal transcriptional changes after SARS-CoV-2 infection, we performed a gene pattern analysis integrating WGCNA and DESeq2.

<p align="left">
  <img src="figures/figure2.png" width="1000">
</p>

- WGCNA was used to cluster genes into co-expression modules based on their expression dynamics across multiple DPI time points.
  
- We specifically focused on modules showing pronounced expression changes at DPI 6, representing early transcriptional responses to infection.

- In parallel, differential expression analysis using DESeq2 identified genes that were significantly altered at DPI 6 relative to mock controls.

- By intersecting DPI 6–associated co-expression modules with differentially expressed genes, we prioritized candidate genes exhibiting coherent early expression patterns and potential long-term regulatory relevance.
  
---


### DEGs Analysis
<p align="left">
  <img src="figures/figure3.png" width="1000">
</p>

---

### Go Term
<p align="left">
  <img src="figures/figure4.png" width="1000">
</p>

---


### Gene Network
<p align="left">
  <img src="figures/figure5.png" width="700">
</p>

---
