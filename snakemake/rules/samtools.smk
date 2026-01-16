rule sort_bam:
    input:
        bam=bam_unsorted
    output:
        bam=bam_sorted
    threads: config["threads"]["samtools"]
    shell:
        r"""
        mkdir -p {OUTDIR}/align
        samtools sort -@ {threads} -o {output.bam} {input.bam}
        """

rule index_bam:
    input:
        bam=bam_sorted
    output:
        bai=bam_bai
    threads: 2
    shell:
        r"""
        samtools index -@ {threads} {input.bam} {output.bai}
        """

rule flagstat:
    input:
        bam=bam_sorted
    output:
        txt=f"{OUTDIR}/align/{{sample}}.flagstat.txt"
    threads: 2
    shell:
        r"""
        samtools flagstat -@ {threads} {input.bam} > {output.txt}
        """

