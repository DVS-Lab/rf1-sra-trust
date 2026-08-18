#!/usr/bin/env python3
"""Audit expected Trust L1 or L2 FEAT products from a readiness manifest."""

from __future__ import annotations

import argparse
import csv
import os
from pathlib import Path


def cope_count(kind: str) -> int:
    if kind == "act":
        return 18
    if kind.startswith("ppi_seed-") or kind in {"nppi-dmn", "nppi-ecn"}:
        return 19
    raise ValueError(f"unsupported analysis type: {kind}")


def l1_path(root: Path, subject: str, session: str, run: str, kind: str) -> Path:
    return root / f"sub-{subject}" / f"ses-{session}" / (
        f"L1_task-trust_ses-{session}_model-1_type-{kind}_run-{run}_sm-5.feat"
    )


def l2_path(root: Path, subject: str, session: str, kind: str) -> Path:
    return root / f"sub-{subject}" / f"ses-{session}" / (
        f"L2_task-trust_ses-{session}_model-1_type-{kind}_sm-5.gfeat"
    )


def l1_required(ncopes: int) -> list[str]:
    required = ["design.mat", "design.con", "mask.nii.gz", "cluster_mask_zstat1.nii.gz"]
    required.extend(f"stats/cope{number}.nii.gz" for number in range(1, ncopes + 1))
    required.extend(f"stats/zstat{number}.nii.gz" for number in range(1, ncopes + 1))
    return required


def l2_required(ncopes: int) -> list[str]:
    required: list[str] = []
    for number in range(1, ncopes + 1):
        prefix = f"cope{number}.feat"
        required.extend((
            f"{prefix}/design.mat",
            f"{prefix}/design.con",
            f"{prefix}/stats/cope1.nii.gz",
            f"{prefix}/stats/zstat1.nii.gz",
            f"{prefix}/cluster_mask_zstat1.nii.gz",
        ))
    return required


def l1_timeseries(output: Path, session: str, run: str, kind: str) -> list[Path]:
    if kind.startswith("ppi_seed-"):
        seed = kind.removeprefix("ppi_seed-")
        return [output.parent / f"ts_task-trust_ses-{session}_mask-{seed}_run-{run}.txt"]
    if kind in {"nppi-dmn", "nppi-ecn"}:
        return [
            output.parent / f"ts_task-trust_ses-{session}_network-smith09-net{network}_run-{run}.txt"
            for network in range(10)
        ]
    return []


def read_manifest(path: Path, level: str) -> list[dict[str, str]]:
    with path.open(newline="", encoding="utf-8") as handle:
        reader = csv.DictReader(handle, delimiter="\t")
        fields = set(reader.fieldnames or ())
        rows = list(reader)
    required = {"subject", "session", *(["run"] if level == "l1" else [])}
    if not required.issubset(fields):
        raise ValueError(f"manifest must contain: {', '.join(sorted(required))}")
    return rows


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--level", choices=("l1", "l2"), required=True)
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--type", required=True, dest="kind")
    parser.add_argument("--fsl-root", type=Path, default=Path(os.environ.get(
        "FSL_DERIVATIVES_ROOT", Path(__file__).resolve().parents[1] / "derivatives" / "fsl"
    )))
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()

    try:
        ncopes = cope_count(args.kind)
        rows = read_manifest(args.manifest, args.level)
    except ValueError as error:
        parser.error(str(error))

    report: list[dict[str, str]] = []
    for row in rows:
        run = row.get("run", "")
        output = (
            l1_path(args.fsl_root, row["subject"], row["session"], run, args.kind)
            if args.level == "l1"
            else l2_path(args.fsl_root, row["subject"], row["session"], args.kind)
        )
        required = l1_required(ncopes) if args.level == "l1" else l2_required(ncopes)
        missing = [relative for relative in required if not (output / relative).is_file()]
        if args.level == "l1":
            missing.extend(
                f"time-series:{path}"
                for path in l1_timeseries(output, row["session"], run, args.kind)
                if not path.is_file() or path.stat().st_size == 0
            )
        if missing:
            report.append({
                "subject": row["subject"], "session": row["session"], "run": run,
                "type": args.kind, "output": str(output), "missing": ",".join(missing),
            })

    args.output.parent.mkdir(parents=True, exist_ok=True)
    fields = ("subject", "session", "run", "type", "output", "missing")
    with args.output.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields, delimiter="\t", lineterminator="\n")
        writer.writeheader()
        writer.writerows(report)

    total = len(rows)
    complete = total - len(report)
    print(f"Manifest units checked: {total}")
    print(f"Fully complete {args.level.upper()} units: {complete}")
    print(f"Incomplete {args.level.upper()} units: {len(report)}")
    print(f"Completeness report: {args.output.resolve()}")
    if report:
        print(f"CHECK FAILED: {len(report)} of {total} {args.level.upper()} unit(s) are incomplete.")
        return 1
    print(f"CHECK PASSED: all {total} {args.level.upper()} {args.kind} unit(s) are complete.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
