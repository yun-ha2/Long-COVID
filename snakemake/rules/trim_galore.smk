rule trim_galore:
    input:
        r1=r1_raw,
        r2=r2_raw
    output:
        r1=r1_trim,
        r2=r2_trim
    threads: config["threads"]["trim"]
    params:
        extra=config.get("trim_galore", {}).get("extra", "--quality 20 --length 20")
    run:
        if TRIMMER != "trim_galore":
            raise ValueError("trim_galore rule called but config.trimmer != trim_galore")

        shell(r"""
        mkdir -p {OUTDIR}/trim
        trim_galore --paired {params.extra} --cores {threads} --output_dir {OUTDIR}/trim {input.r1} {input.r2}
        """)

        import glob, shutil
        r1_out = glob.glob(f"{OUTDIR}/trim/*{wildcards.sample}*val_1.fq.gz")
        r2_out = glob.glob(f"{OUTDIR}/trim/*{wildcards.sample}*val_2.fq.gz")

        if len(r1_out) != 1 or len(r2_out) != 1:
            raise RuntimeError("Unexpected Trim Galore outputs; check input names and output directory.")

        shutil.copyfile(r1_out[0], output.r1)
        shutil.copyfile(r2_out[0], output.r2)

