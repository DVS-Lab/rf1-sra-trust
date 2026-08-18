from __future__ import annotations

import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class NotebookTests(unittest.TestCase):
    def test_public_notebooks_are_structurally_valid_and_aligned(self) -> None:
        names = ("01_download_and_preprocess.ipynb", "02_first_level_feat.ipynb", "03_second_level_feat.ipynb")
        texts = []
        for name in names:
            path = ROOT / "notebooks" / name
            document = json.loads(path.read_text(encoding="utf-8"))
            self.assertEqual(document["nbformat"], 4)
            self.assertGreaterEqual(len(document["cells"]), 8)
            text = "".join("".join(cell.get("source", [])) for cell in document["cells"])
            self.assertNotIn("/ZPOOL", text)
            self.assertNotIn("rf1-sra-linux2", text)
            texts.append(text)
        self.assertIn("ds005123", texts[0]); self.assertIn("1.1.3", texts[0]); self.assertIn("fmriprep/25.2.5", texts[0])
        self.assertIn("code'/'gen3colfiles.sh", texts[1]); self.assertIn("code'/'L1stats.sh", texts[1]); self.assertIn("fsl/6.0.7.22", texts[1])
        self.assertIn("code'/'L2stats.sh", texts[2]); self.assertIn("set fmri(mixed_yn) 3", texts[2]); self.assertIn("runs 1 and 2", texts[2])


if __name__ == "__main__": unittest.main()
