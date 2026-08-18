#!/usr/bin/env python3
"""Describe canonical Trust events without changing inclusion or analysis inputs."""

from __future__ import annotations

import argparse
import csv
import os
import re
from collections import Counter
from pathlib import Path

EXPECTED = (
    "choice_computer", "choice_friend", "choice_stranger",
    "outcome_computer_defect", "outcome_computer_recip",
    "outcome_friend_defect", "outcome_friend_recip",
    "outcome_stranger_defect", "outcome_stranger_recip",
)
NAME_RE = re.compile(r"^sub-(?P<subject>[^_]+)_ses-(?P<session>[^_]+)_task-trust_run-(?P<run>[^_]+)_events\.tsv$")


def events_from_manifest(manifest: Path, bids_root: Path) -> list[Path]:
    with manifest.open(newline="", encoding="utf-8") as handle:
        reader = csv.DictReader(handle, delimiter="\t")
        fields = set(reader.fieldnames or ())
        rows = list(reader)
    required = {"subject", "session", "run"}
    if not required.issubset(fields):
        raise ValueError(f"manifest must contain: {', '.join(sorted(required))}")
    return [
        bids_root / f"sub-{row['subject']}" / f"ses-{row['session']}" / "func"
        / f"sub-{row['subject']}_ses-{row['session']}_task-trust_run-{row['run']}_events.tsv"
        for row in rows
    ]


def summarize(path: Path) -> dict[str, object]:
    with path.open(newline="", encoding="utf-8") as handle:
        rows = list(csv.DictReader(handle, delimiter="\t"))
    counts = Counter(row.get("trial_type", "") for row in rows)
    choices = [row for row in rows if row.get("trial_type", "").startswith("choice_")]
    misses = counts["missed_trial"]
    zero = sum(row.get("trust_value", "").strip() in {"0", "0.0"} for row in choices)
    return {
        "event_rows": len(rows), "trials": len(choices) + misses,
        "valid_choices": len(choices), "misses": misses, "zero_investments": zero,
        **{name: counts[name] for name in EXPECTED},
        "missing_expected": ",".join(name for name in EXPECTED if not counts[name]),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("events", nargs="*", type=Path)
    parser.add_argument("--manifest", type=Path, help="L1 manifest with subject, session, and run columns")
    parser.add_argument("--bids-root", type=Path, default=Path(os.environ.get(
        "BIDS_ROOT", "/ZPOOL/data/projects/rf1-sra-linux2/bids"
    )))
    parser.add_argument("--output", type=Path)
    parser.add_argument("--fail-on-missing-categories", action="store_true")
    args = parser.parse_args()
    if bool(args.events) == bool(args.manifest):
        parser.error("provide event files or --manifest, but not both")
    events = events_from_manifest(args.manifest, args.bids_root) if args.manifest else args.events
    fields = ("subject", "session", "run", "file", "event_rows", "trials", "valid_choices", "misses", "zero_investments", *EXPECTED, "missing_expected")
    records = []
    for path in events:
        if not path.is_file():
            parser.error(f"event file not found: {path}")
        match = NAME_RE.match(path.name)
        identity = match.groupdict() if match else {"subject": "", "session": "", "run": ""}
        record = {**identity, "file": str(path), **summarize(path)}; records.append(record)
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
    handle = args.output.open("w", newline="", encoding="utf-8") if args.output else __import__("sys").stdout
    try:
        writer = csv.DictWriter(handle, fieldnames=fields, delimiter="\t", lineterminator="\n")
        writer.writeheader(); writer.writerows(records)
    finally:
        if args.output: handle.close()
    missing = sum(bool(record["missing_expected"]) for record in records)
    nonstandard = sum(record["trials"] != 42 for record in records)
    print(f"Trust runs checked: {len(records)}")
    print(f"Runs missing expected categories: {missing}")
    print(f"Runs with trial count other than 42: {nonstandard}")
    if args.output:
        print(f"QC table: {args.output.resolve()}")
    if args.fail_on_missing_categories and missing:
        print(f"CHECK FAILED: {missing} Trust run(s) lack one or more expected EV categories.")
        return 1
    print(f"CHECK PASSED: {len(records)} canonical Trust event file(s) audited.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
