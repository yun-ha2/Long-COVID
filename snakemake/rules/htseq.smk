rule htseq:
    input:
        bam=bam_sorted
    output:
        txt=counts_txt
    threads: config["threads"]["quant"]
    params:
        gtf=config["reference"]["gtf"],
        extra=config.get("htseq", {}).get("extra", "--type exon --idattr gene_id --mode union --stranded no")
    run:
        if QUANT != "htseq":
            raise ValueError("htseq rule called but config.quantifier != htseq")
        shell(r"""
        mkdir -p {OUTDIR}/counts
        samtools view -@ {min(threads, 8)} -h {input.bam} \
          | htseq-count {params.extra} - {params.gtf} > {output.txt}
        """)

