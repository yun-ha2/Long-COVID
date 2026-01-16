rule trimmomatic:
    input:
        r1=r1_raw,
        r2=r2_raw
    output:
        r1=r1_trim,
        r2=r2_trim,
        r1_unp=f"{OUTDIR}/trim/{{sample}}_R1.unpaired.fq.gz",
        r2_unp=f"{OUTDIR}/trim/{{sample}}_R2.unpaired.fq.gz"
    threads: config["threads"]["trim"]
    params:
        adapters=config.get("trimmomatic", {}).get("adapters", None),
        extra=config.get("trimmomatic", {}).get("extra", "LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:20")
    run:
        if TRIMMER != "trimmomatic":
            raise ValueError("trimmomatic rule called but config.trimmer != trimmomatic")

        clip = ""
        if params.adapters:
            clip = f"ILLUMINACLIP:{params.adapters}:2:30:10"

        shell(r"""
        mkdir -p {OUTDIR}/trim
        trimmomatic PE -threads {threads} \
          {input.r1} {input.r2} \
          {output.r1} {output.r1_unp} \
          {output.r2} {output.r2_unp} \
          {clip} {params.extra}
        """)

