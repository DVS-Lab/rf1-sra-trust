#!/usr/bin/env python3
"""Build Trust L2 readiness from complete run-1 and run-2 L1 outputs."""

from __future__ import annotations

import argparse
import csv
import os
from pathlib import Path


def normalize_type(value: str) -> str:
    if value == "act" or value in {"nppi-dmn", "nppi-ecn"} or value.startswith("ppi_seed-"):
        return value
    raise argparse.ArgumentTypeError("type must be act, ppi_seed-<seed>, nppi-dmn, or nppi-ecn")


def l1_path(root: Path, subject: str, session: str, run: str, kind: str) -> Path:
    return root / f"sub-{subject}" / f"ses-{session}" / (
        f"L1_task-trust_ses-{session}_model-1_type-{kind}_run-{run}_sm-5.feat"
    )


def read_sublist(path: Path) -> list[str]:
    values = []
    for raw in path.read_text(encoding="utf-8").splitlines():
        value = raw.split("#", 1)[0].strip().removeprefix("sub-")
        if value:
            values.append(value)
    return sorted(dict.fromkeys(values))


def write(path: Path, header: tuple[str, ...], rows) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle, delimiter="\t", lineterminator="\n")
        writer.writerow(header); writer.writerows(rows)


def main() -> int:
    root = Path(__file__).resolve().parents[1]
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--fsl-root", type=Path, default=Path(os.environ.get("FSL_DERIVATIVES_ROOT", root / "derivatives/fsl")))
    parser.add_argument("--sublist", type=Path)
    parser.add_argument("--sessions", default="01")
    parser.add_argument("--type", required=True, type=normalize_type)
    parser.add_argument("--output", type=Path, default=root / "logs/runlists/L2-ready.tsv")
    parser.add_argument("--missing-output", type=Path, default=root / "logs/runlists/L2-missing.tsv")
    args = parser.parse_args()
    sessions = [v.strip().removeprefix("ses-") for v in args.sessions.split(",") if v.strip()]
    subjects = read_sublist(args.sublist) if args.sublist else sorted(
        p.name.removeprefix("sub-") for p in args.fsl_root.glob("sub-*") if p.is_dir()
    )
    ready, missing = [], []
    for subject in subjects:
        for session in sessions:
            absent = [f"run-{run}" for run in ("1", "2")
                      if not (l1_path(args.fsl_root, subject, session, run, args.type)
                              / "cluster_mask_zstat1.nii.gz").is_file()]
            (missing if absent else ready).append(
                (subject, session, ",".join(absent)) if absent else (subject, session)
            )
    write(args.output, ("subject", "session"), ready)
    write(args.missing_output, ("subject", "session", "missing_l1"), missing)
    print(f"L2 type: {args.type}")
    print(f"Ready subject-sessions: {len(ready)}")
    print(f"Incomplete subject-sessions: {len(missing)}")
    print(f"Ready manifest: {args.output.resolve()}")
    print(f"Missing report: {args.missing_output.resolve()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
