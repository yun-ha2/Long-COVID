rule hisat2_align:
    input:
        r1=r1_in,
        r2=r2_in,
        # ensure trimming happens when needed
        _trim_ok=lambda wc: [] if TRIMMER == "none" else ( [r1_trim(wc), r2_trim(wc)] )
    output:
        bam=bam_unsorted
    threads: config["threads"]["align"]
    params:
        idx=config["reference"]["hisat2_index"],
        extra=config.get("hisat2", {}).get("extra", "--dta")
    run:
        if ALIGNER != "hisat2":
            raise ValueError("hisat2_align rule called but config.aligner != hisat2")

        shell(r"""
        mkdir -p {OUTDIR}/align
        hisat2 -x {params.idx} -1 {input.r1} -2 {input.r2} -p {threads} {params.extra} \
          | samtools view -@ {min(threads, 8)} -bS -o {output.bam} -
        """)

