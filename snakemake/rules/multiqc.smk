rule multiqc:
    input:
        expand(f"{OUTDIR}/qc/fastqc/{{sample}}_R1_fastqc.zip", sample=SAMPLES),
        expand(f"{OUTDIR}/qc/fastqc/{{sample}}_R2_fastqc.zip", sample=SAMPLES),
        expand(f"{OUTDIR}/align/{{sample}}.flagstat.txt", sample=SAMPLES)
    output:
        html=f"{OUTDIR}/qc/multiqc/multiqc_report.html"
    threads: config["threads"]["multiqc"]
    run:
        if not config.get("multiqc", False):
            raise ValueError("multiqc rule called but config.multiqc is false")
        shell(r"""
        mkdir -p {OUTDIR}/qc/multiqc
        multiqc -o {OUTDIR}/qc/multiqc {OUTDIR}/qc {OUTDIR}/align
        """)

