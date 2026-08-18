from __future__ import annotations

import csv
import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FIXTURE = ROOT / "tests/fixtures/synthetic_trust_events.tsv"


class EventConversionTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.base = Path(self.temp.name)
        self.bids = self.base / "bids"
        self.fsl = self.base / "fsl"
        self.func = self.bids / "sub-99999/ses-01/func"
        self.func.mkdir(parents=True)
        self.events = self.func / "sub-99999_ses-01_task-trust_run-1_events.tsv"
        shutil.copyfile(FIXTURE, self.events)
        self.env = {**os.environ, "BIDS_ROOT": str(self.bids), "FSL_DERIVATIVES_ROOT": str(self.fsl)}

    def tearDown(self) -> None:
        self.temp.cleanup()

    def run_generator(self, *extra: str, check: bool = True):
        return subprocess.run(
            ["bash", "code/gen3colfiles.sh", "--subject", "99999", "--session", "01", "--run", "1", *extra],
            cwd=ROOT, env=self.env, text=True, capture_output=True, check=check,
        )

    def test_all_types_zero_investment_and_timing_are_preserved(self) -> None:
        self.run_generator()
        prefix = self.fsl / "EVfiles/sub-99999/ses-01/trust/run-1"
        expected = {
            "choice_computer", "choice_friend", "choice_stranger",
            "outcome_computer_defect", "outcome_computer_recip",
            "outcome_friend_defect", "outcome_friend_recip",
            "outcome_stranger_defect", "outcome_stranger_recip", "missed_trial",
        }
        self.assertEqual({p.stem.removeprefix("run-1_") for p in prefix.parent.glob("run-1_*.txt")}, expected)
        self.assertEqual((prefix.parent / "run-1_outcome_computer_defect.txt").read_text(), "2\t2.05\t1\n")
        friend_choices = (prefix.parent / "run-1_choice_friend.txt").read_text().splitlines()
        self.assertEqual(len(friend_choices), 3)  # includes the zero-investment choice
        self.assertEqual(len(list(prefix.parent.glob("run-1_outcome_*.txt"))), 6)  # no invented zero outcome

    def test_overwrite_removes_stale_miss(self) -> None:
        self.run_generator()
        with self.events.open(newline="", encoding="utf-8") as handle:
            rows = [row for row in csv.DictReader(handle, delimiter="\t") if row["trial_type"] != "missed_trial"]
        with self.events.open("w", newline="", encoding="utf-8") as handle:
            writer = csv.DictWriter(handle, fieldnames=list(rows[0]), delimiter="\t", lineterminator="\n")
            writer.writeheader(); writer.writerows(rows)
        self.run_generator("--overwrite")
        self.assertFalse((self.fsl / "EVfiles/sub-99999/ses-01/trust/run-1_missed_trial.txt").exists())

    def test_missing_scientific_category_stops(self) -> None:
        with self.events.open(newline="", encoding="utf-8") as handle:
            rows = [row for row in csv.DictReader(handle, delimiter="\t") if row["trial_type"] != "outcome_friend_defect"]
        with self.events.open("w", newline="", encoding="utf-8") as handle:
            writer = csv.DictWriter(handle, fieldnames=list(rows[0]), delimiter="\t", lineterminator="\n")
            writer.writeheader(); writer.writerows(rows)
        result = self.run_generator(check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("outcome_friend_defect", result.stderr)
        self.assertFalse((self.fsl / "EVfiles/sub-99999/ses-01/trust").exists())


if __name__ == "__main__": unittest.main()
