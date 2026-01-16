# Long-COVID

<p align="center">
  <img src="figures/figure1.png" width="700">
</p>

## RNA-seq Analysis Overview

### Workflow Management with Snakemake
The RNA-seq analysis workflow was implemented using Snakemake, enabling reproducible, scalable, and automated execution of read processing and quantification steps.

All software dependencies were managed via Conda, and analysis parameters were controlled through a centralized configuration file.

### Pipeline Execution
```bash
snakemake --use-conda -j 32
```
