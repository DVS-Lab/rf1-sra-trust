#!/usr/bin/env python3
"""Build a session/run-aware Trust L1 readiness manifest from canonical inputs."""

from __future__ import annotations

import argparse
import csv
import os
import re
from pathlib import Path

EVENT_RE = re.compile(
    r"^sub-(?P<subject>[^_]+)_ses-(?P<session>[^_]+)_task-trust_run-(?P<run>[^_]+)_events\.tsv$"
)


def read_sublist(path: Path) -> list[str]:
    values = []
    for raw in path.read_text(encoding="utf-8").splitlines():
        value = raw.split("#", 1)[0].strip().removeprefix("sub-")
        if value:
            values.append(value)
    return sorted(dict.fromkeys(values))


def discover_subjects(root: Path) -> list[str]:
    return sorted(p.name.removeprefix("sub-") for p in root.glob("sub-*") if p.is_dir())


def input_paths(subject: str, session: str, run: str, bids: Path, fmriprep: Path, confounds: Path):
    stem = f"sub-{subject}_ses-{session}_task-trust_run-{run}"
    return (
        bids / f"sub-{subject}" / f"ses-{session}" / "func" / f"{stem}_events.tsv",
        fmriprep / f"sub-{subject}" / f"ses-{session}" / "func"
        / f"{stem}_part-mag_space-MNI152NLin6Asym_desc-preproc_bold.nii.gz",
        confounds / f"sub-{subject}" / f"{stem}_desc-TedanaPlusConfounds.tsv",
    )


def build(subjects: list[str], sessions: list[str], bids: Path, fmriprep: Path, confounds: Path):
    ready, missing = [], []
    for subject in subjects:
        for session in sessions:
            func = bids / f"sub-{subject}" / f"ses-{session}" / "func"
            if not func.is_dir():
                missing.append((subject, session, "", "missing BIDS session func directory"))
                continue
            runs = []
            for path in sorted(func.glob(f"sub-{subject}_ses-{session}_task-trust_run-*_events.tsv")):
                match = EVENT_RE.match(path.name)
                if match:
                    runs.append(match.group("run"))
            if not runs:
                missing.append((subject, session, "", "no canonical Trust events"))
                continue
            key = lambda value: (not value.isdigit(), int(value) if value.isdigit() else value)
            for run in sorted(dict.fromkeys(runs), key=key):
                paths = input_paths(subject, session, run, bids, fmriprep, confounds)
                absent = [name for name, path in zip(("events", "BOLD", "confounds"), paths)
                          if not path.is_file() or path.stat().st_size == 0]
                if absent:
                    missing.append((subject, session, run, ",".join(absent)))
                else:
                    ready.append((subject, session, run))
    return ready, missing


def write(path: Path, header: tuple[str, ...], rows) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle, delimiter="\t", lineterminator="\n")
        writer.writerow(header); writer.writerows(rows)


def main() -> int:
    root = Path(__file__).resolve().parents[1]
    upstream = Path(os.environ.get("RF1_SRA_UPSTREAM_ROOT", "/ZPOOL/data/projects/rf1-sra-linux2"))
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--bids-root", type=Path, default=Path(os.environ.get("BIDS_ROOT", upstream / "bids")))
    parser.add_argument("--fmriprep-root", type=Path, default=Path(os.environ.get("FMRIPREP_ROOT", upstream / "derivatives/fmriprep")))
    parser.add_argument("--confounds-root", type=Path, default=Path(os.environ.get("CONFOUNDS_ROOT", upstream / "derivatives/fsl/confounds_tedana")))
    parser.add_argument("--sublist", type=Path)
    parser.add_argument("--sessions", default="01")
    parser.add_argument("--output", type=Path, default=root / "logs/runlists/L1-ready.tsv")
    parser.add_argument("--missing-output", type=Path, default=root / "logs/runlists/L1-missing.tsv")
    args = parser.parse_args()
    sessions = [v.strip().removeprefix("ses-") for v in args.sessions.split(",") if v.strip()]
    if not args.bids_root.is_dir():
        parser.error(f"BIDS root not found: {args.bids_root}")
    subjects = read_sublist(args.sublist) if args.sublist else discover_subjects(args.bids_root)
    ready, missing = build(subjects, sessions, args.bids_root, args.fmriprep_root, args.confounds_root)
    write(args.output, ("subject", "session", "run"), ready)
    write(args.missing_output, ("subject", "session", "run", "reason"), missing)
    paired = sum({run for s, se, run in ready if s == sub and se == ses} >= {"1", "2"}
                 for sub, ses in {(s, se) for s, se, _ in ready})
    print(f"Subjects considered: {len(subjects)}")
    print(f"Ready Trust L1 runs: {len(ready)}")
    print(f"Subject-sessions with ready runs 1 and 2: {paired}")
    print(f"Missing-input rows: {len(missing)}")
    print(f"Ready manifest: {args.output.resolve()}")
    print(f"Missing-input report: {args.missing_output.resolve()}")
    return 0 if ready else 1


if __name__ == "__main__":
    raise SystemExit(main())
