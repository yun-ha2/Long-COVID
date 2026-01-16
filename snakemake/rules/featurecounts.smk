rule featurecounts:
    input:
        bam=bam_sorted
    output:
        txt=counts_txt
    threads: config["threads"]["quant"]
    params:
        gtf=config["reference"]["gtf"],
        extra=config.get("featurecounts", {}).get("extra", "-p -B -C -t exon -g gene_id")
    run:
        if QUANT != "featurecounts":
            raise ValueError("featurecounts rule called but config.quantifier != featurecounts")
        shell(r"""
        mkdir -p {OUTDIR}/counts
        featureCounts -T {threads} -a {params.gtf} -o {output.txt} {params.extra} {input.bam}
        """)

