rule fastqc:
    input:
        r1=r1_raw,
        r2=r2_raw
    output:
        html1=f"{OUTDIR}/qc/fastqc/{{sample}}_R1_fastqc.html",
        zip1=f"{OUTDIR}/qc/fastqc/{{sample}}_R1_fastqc.zip",
        html2=f"{OUTDIR}/qc/fastqc/{{sample}}_R2_fastqc.html",
        zip2=f"{OUTDIR}/qc/fastqc/{{sample}}_R2_fastqc.zip"
    threads: config["threads"]["fastqc"]
    params:
        extra=config.get("fastqc", {}).get("extra", "")
    shell:
        r"""
        mkdir -p {OUTDIR}/qc/fastqc
        fastqc -t {threads} -o {OUTDIR}/qc/fastqc {params.extra} {input.r1} {input.r2}
        """

