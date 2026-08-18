#!/usr/bin/env python3
"""Describe canonical Trust events without changing inclusion or analysis inputs."""

from __future__ import annotations

import argparse
import csv
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
    parser.add_argument("events", nargs="+", type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    fields = ("subject", "session", "run", "file", "event_rows", "trials", "valid_choices", "misses", "zero_investments", *EXPECTED, "missing_expected")
    records = []
    for path in args.events:
        match = NAME_RE.match(path.name)
        identity = match.groupdict() if match else {"subject": "", "session": "", "run": ""}
        record = {**identity, "file": str(path), **summarize(path)}; records.append(record)
    handle = args.output.open("w", newline="", encoding="utf-8") if args.output else __import__("sys").stdout
    try:
        writer = csv.DictWriter(handle, fieldnames=fields, delimiter="\t", lineterminator="\n")
        writer.writeheader(); writer.writerows(records)
    finally:
        if args.output: handle.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
