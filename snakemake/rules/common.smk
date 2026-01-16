from pathlib import Path
import pandas as pd

OUTDIR = config.get("outdir", "results")

def load_samples(tsv_path: str):
    tsv_path = Path(tsv_path)
    df = pd.read_csv(tsv_path, sep="\t", dtype=str)

    required = ["sample", "fq1", "fq2"]
    missing = [c for c in required if c not in df.columns]
    if missing:
        raise ValueError(f"samples.tsv missing required columns: {missing}")

    df = df[required].dropna().copy()
    df["sample"] = df["sample"].astype(str).str.strip()
    df["fq1"] = df["fq1"].astype(str).str.strip()
    df["fq2"] = df["fq2"].astype(str).str.strip()

    if df["sample"].duplicated().any():
        dup = df.loc[df["sample"].duplicated(), "sample"].tolist()
        raise ValueError(f"Duplicate sample IDs in samples.tsv: {dup}")

    base = tsv_path.parent.resolve()

    def _resolve(p: str) -> str:
        pth = Path(p)
        return str((base / pth).resolve()) if not pth.is_absolute() else str(pth)

    df["fq1"] = df["fq1"].map(_resolve)
    df["fq2"] = df["fq2"].map(_resolve)

    samples = df["sample"].tolist()
    fq1 = dict(zip(df["sample"], df["fq1"]))
    fq2 = dict(zip(df["sample"], df["fq2"]))
    return samples, fq1, fq2

SAMPLES, FQ1, FQ2 = load_samples(config["samples_tsv"])

TRIMMER = str(config.get("trimmer", "none")).lower()
ALIGNER = str(config.get("aligner", "hisat2")).lower()
QUANT   = str(config.get("quantifier", "featurecounts")).lower()

if TRIMMER not in {"none", "trim_galore", "trimmomatic"}:
    raise ValueError("config.trimmer must be: none | trim_galore | trimmomatic")
if ALIGNER not in {"hisat2", "star"}:
    raise ValueError("config.aligner must be: hisat2 | star")
if QUANT not in {"featurecounts", "htseq"}:
    raise ValueError("config.quantifier must be: featurecounts | htseq")

def r1_raw(wc): return FQ1[wc.sample]
def r2_raw(wc): return FQ2[wc.sample]

def r1_trim(wc): return f"{OUTDIR}/trim/{wc.sample}_R1.trim.fq.gz"
def r2_trim(wc): return f"{OUTDIR}/trim/{wc.sample}_R2.trim.fq.gz"

def r1_in(wc):
    return r1_raw(wc) if TRIMMER == "none" else r1_trim(wc)

def r2_in(wc):
    return r2_raw(wc) if TRIMMER == "none" else r2_trim(wc)

def bam_unsorted(wc): return f"{OUTDIR}/align/{wc.sample}.unsorted.bam"
def bam_sorted(wc):   return f"{OUTDIR}/align/{wc.sample}.sorted.bam"
def bam_bai(wc):      return f"{OUTDIR}/align/{wc.sample}.sorted.bam.bai"

def counts_txt(wc):   return f"{OUTDIR}/counts/{wc.sample}.counts.txt"

