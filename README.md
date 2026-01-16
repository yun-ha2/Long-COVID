# Long-COVID

Long COVID refers to the persistence of neurological and cognitive symptoms after SARS-CoV-2 infection.  

To investigate transcriptional changes underlying these long-term effects, RNA-seq analysis was performed on brain tissues from a SARS-CoV-2 mouse model.
<p align="center">
  <img src="figures/figure1.png" width="300">
</p>

---

## RNA-seq Analysis Overview

### Workflow with Snakemake
The RNA-seq analysis workflow was implemented using Snakemake, enabling reproducible, scalable, and automated execution of read processing and quantification steps.

All software dependencies were managed via Conda, and analysis parameters were controlled through a centralized configuration file.

### Pipeline Execution
```bash
snakemake --use-conda -j 32
```
