rule star_align:
    input:
        r1=r1_in,
        r2=r2_in,
        _trim_ok=lambda wc: [] if TRIMMER == "none" else ( [r1_trim(wc), r2_trim(wc)] )
    output:
        bam=bam_unsorted
    threads: config["threads"]["align"]
    params:
        idx=config["reference"]["star_index"],
        extra=config.get("star", {}).get("extra", "")
    run:
        if ALIGNER != "star":
            raise ValueError("star_align rule called but config.aligner != star")

        shell(r"""
        mkdir -p {OUTDIR}/align {OUTDIR}/align/star_tmp/{wildcards.sample}
        STAR --runThreadN {threads} --genomeDir {params.idx} \
             --readFilesIn {input.r1} {input.r2} \
             --readFilesCommand zcat \
             --outFileNamePrefix {OUTDIR}/align/star_tmp/{wildcards.sample}/ \
             {params.extra}
        mv {OUTDIR}/align/star_tmp/{wildcards.sample}/Aligned.out.bam {output.bam}
        """)

