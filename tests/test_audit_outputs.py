from __future__ import annotations

import csv
import importlib.util
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("audit_outputs", ROOT / "code" / "audit_outputs.py")
audit = importlib.util.module_from_spec(spec); assert spec.loader; spec.loader.exec_module(audit)


class AuditOutputTests(unittest.TestCase):
    def test_l1_contract_has_every_cope_and_zstat(self) -> None:
        required = audit.l1_required(18)
        self.assertIn("stats/cope18.nii.gz", required)
        self.assertIn("stats/zstat18.nii.gz", required)
        self.assertIn("cluster_mask_zstat1.nii.gz", required)

    def test_l2_contract_checks_every_cope_directory(self) -> None:
        required = audit.l2_required(19)
        self.assertIn("cope1.feat/stats/zstat1.nii.gz", required)
        self.assertIn("cope19.feat/cluster_mask_zstat1.nii.gz", required)

    def test_seed_and_network_time_series_contracts(self) -> None:
        output = Path("/fsl/sub-1/ses-01/model.feat")
        seed = audit.l1_timeseries(output, "01", "2", "ppi_seed-VS")
        self.assertEqual(seed, [Path("/fsl/sub-1/ses-01/ts_task-trust_ses-01_mask-VS_run-2.txt")])
        network = audit.l1_timeseries(output, "01", "1", "nppi-dmn")
        self.assertEqual(len(network), 10)
        self.assertEqual(network[-1], Path("/fsl/sub-1/ses-01/ts_task-trust_ses-01_network-smith09-net9_run-1.txt"))

    def test_manifest_requires_run_for_l1(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            manifest = Path(tmp) / "manifest.tsv"
            with manifest.open("w", newline="", encoding="utf-8") as handle:
                writer = csv.writer(handle, delimiter="\t")
                writer.writerow(("subject", "session")); writer.writerow(("1", "01"))
            with self.assertRaises(ValueError):
                audit.read_manifest(manifest, "l1")


if __name__ == "__main__":
    unittest.main()
