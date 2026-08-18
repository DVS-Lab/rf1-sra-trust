from __future__ import annotations

import importlib.util
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def load(name: str):
    spec = importlib.util.spec_from_file_location(name, ROOT / "code" / f"{name}.py")
    module = importlib.util.module_from_spec(spec); assert spec.loader; spec.loader.exec_module(module); return module


class ManifestTests(unittest.TestCase):
    def test_l1_discovers_actual_runs_and_reports_missing_inputs(self) -> None:
        mod = load("build_L1_manifest")
        with tempfile.TemporaryDirectory() as tmp:
            base = Path(tmp); bids=base/"bids"; fmri=base/"fmriprep"; conf=base/"confounds"
            func=bids/"sub-1/ses-01/func"; func.mkdir(parents=True)
            for run in ("1", "2"):
                stem=f"sub-1_ses-01_task-trust_run-{run}"
                (func/f"{stem}_events.tsv").write_text("onset\tduration\ttrial_type\n0\t1\tx\n")
                bold=fmri/"sub-1/ses-01/func"/f"{stem}_part-mag_space-MNI152NLin6Asym_desc-preproc_bold.nii.gz"
                bold.parent.mkdir(parents=True, exist_ok=True); bold.write_bytes(b"x")
                if run == "1":
                    c=conf/"sub-1"/f"{stem}_desc-TedanaPlusConfounds.tsv"; c.parent.mkdir(parents=True); c.write_text("x\n")
            ready, missing = mod.build(["1"], ["01"], bids, fmri, conf)
            self.assertEqual(ready, [("1", "01", "1")])
            self.assertEqual(missing, [("1", "01", "2", "confounds")])

    def test_l2_path_is_session_aware(self) -> None:
        mod = load("build_L2_manifest")
        path = mod.l1_path(Path("/fsl"), "1", "02", "2", "nppi-dmn")
        self.assertEqual(str(path), "/fsl/sub-1/ses-02/L1_task-trust_ses-02_model-1_type-nppi-dmn_run-2_sm-5.feat")


if __name__ == "__main__": unittest.main()
