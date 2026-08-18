from __future__ import annotations

import os
import re
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FIXTURE = ROOT / "tests/fixtures/synthetic_trust_events.tsv"


class WorkflowContractTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory(); self.base = Path(self.temp.name)
        self.bids=self.base/"bids"; self.fmri=self.base/"fmriprep"; self.conf=self.base/"confounds"; self.fsl=self.base/"fsl"; self.bin=self.base/"bin"; self.bin.mkdir()
        scripts = {
            "fslnvols": "echo 100\n",
            "fslval": "case $2 in dim1) echo 65;; dim2) echo 77;; dim3) echo 65;; *) echo 3.0;; esac\n",
            "fslmeants": "out=''; while (($#)); do [[ $1 == -o ]] && { out=$2; shift 2; } || shift; done; yes 0 | head -100 > \"$out\"\n",
            "fsl_glm": "out=''; while (($#)); do [[ $1 == -o ]] && { out=$2; shift 2; } || shift; done; yes 0 | head -100 > \"$out\"\n",
        }
        for name, body in scripts.items():
            path=self.bin/name; path.write_text("#!/usr/bin/env bash\nset -e\n"+body); path.chmod(0o755)
        self.env={**os.environ,"BIDS_ROOT":str(self.bids),"FMRIPREP_ROOT":str(self.fmri),"CONFOUNDS_ROOT":str(self.conf),"FSL_DERIVATIVES_ROOT":str(self.fsl),"PATH":f"{self.bin}:{os.environ.get('PATH','')}"}
        self.prepare_run("1", misses=True); self.prepare_run("2", misses=False)

    def tearDown(self): self.temp.cleanup()

    def prepare_run(self, run: str, misses: bool):
        stem=f"sub-99999_ses-01_task-trust_run-{run}"; func=self.bids/"sub-99999/ses-01/func"; func.mkdir(parents=True,exist_ok=True)
        if misses: shutil.copyfile(FIXTURE, func/f"{stem}_events.tsv")
        else:
            lines=FIXTURE.read_text().splitlines(); (func/f"{stem}_events.tsv").write_text("\n".join(x for x in lines if "\tmissed_trial\t" not in x)+"\n")
        bold=self.fmri/"sub-99999/ses-01/func"/f"{stem}_part-mag_space-MNI152NLin6Asym_desc-preproc_bold.nii.gz"; bold.parent.mkdir(parents=True,exist_ok=True); bold.write_bytes(b"x")
        conf=self.conf/"sub-99999"/f"{stem}_desc-TedanaPlusConfounds.tsv"; conf.parent.mkdir(parents=True,exist_ok=True); conf.write_text("motion\n0\n")
        subprocess.run(["bash","code/gen3colfiles.sh","--subject","99999","--run",run],cwd=ROOT,env=self.env,check=True,capture_output=True)

    def run_script(self,*args): return subprocess.run(["bash",*args],cwd=ROOT,env=self.env,text=True,capture_output=True,check=True)

    def fake_activation(self, run: str):
        feat=self.fsl/"sub-99999/ses-01"/f"L1_task-trust_ses-01_model-1_type-act_run-{run}_sm-5.feat"; (feat/"stats").mkdir(parents=True,exist_ok=True)
        (feat/"mask.nii.gz").write_bytes(b"x"); (feat/"cluster_mask_zstat1.nii.gz").write_bytes(b"x"); (feat/"stats/cope18.nii.gz").write_bytes(b"x")

    def test_scientific_template_contract(self):
        text=(ROOT/"templates/L1_task-trust_model-1_type-act.fsf").read_text()
        self.assertIn("set fmri(evs_orig) 10",text); self.assertIn("set fmri(ncon_orig) 18",text); self.assertIn("set fmri(featwatcher_yn) 0",text)
        evs=[m.group(1) for m in re.finditer(r'set fmri\(custom\d+\) "EVDIR_([^\"]+)\.txt"',text)]
        self.assertEqual(evs,["choice_computer","choice_friend","choice_stranger","outcome_computer_defect","outcome_computer_recip","outcome_friend_defect","outcome_friend_recip","outcome_stranger_defect","outcome_stranger_recip"])
        expected = [
            [1,0,0,0,0,0,0,0,0,0], [0,1,0,0,0,0,0,0,0,0], [0,0,1,0,0,0,0,0,0,0],
            [0,0,0,1,0,0,0,0,0,0], [0,0,0,0,1,0,0,0,0,0], [0,0,0,0,0,1,0,0,0,0],
            [0,0,0,0,0,0,1,0,0,0], [0,0,0,0,0,0,0,1,0,0], [0,0,0,0,0,0,0,0,1,0],
            [0,0,0,-1,1,-1,1,-1,1,0], [-1,.5,.5,0,0,0,0,0,0,0], [0,0,0,0,0,-1,1,1,-1,0],
            [0,1,-1,0,0,0,0,0,0,0], [-1,1,0,0,0,0,0,0,0,0], [-1,0,1,0,0,0,0,0,0,0],
            [0,0,0,0,-1,0,1,0,0,0], [0,0,0,-1,0,1,0,0,0,0], [0,0,0,1,-1,-1,1,0,0,0],
        ]
        actual=[]
        for contrast in range(1,19):
            actual.append([float(re.search(rf'^set fmri\(con_real{contrast}\.{ev}\) (.+)$',text,re.M).group(1)) for ev in range(1,11)])
        self.assertEqual(actual, expected)
        for ev in range(1,11):
            self.assertIn(f"set fmri(convolve{ev}) 3", text)
            for other in range(0,11): self.assertIn(f"set fmri(ortho{ev}.{other}) 0", text)
        for kind in ("ppi", "nppi"):
            connectivity=(ROOT/f"templates/L1_task-trust_model-1_type-{kind}.fsf").read_text()
            self.assertIn("set fmri(ncon_orig) 19", connectivity)
            self.assertIn("set fmri(featwatcher_yn) 0", connectivity)
        self.assertNotIn("model-01", "\n".join(str(p) for p in (ROOT/"templates").glob("L[12]*")))

    def test_render_activation_seed_and_network_ppi(self):
        self.run_script("code/L1stats.sh","99999","1","0","--render-only")
        subject=self.fsl/"sub-99999/ses-01"; act=(subject/"L1_sub-99999_task-trust_ses-01_model-1_type-act_run-1.fsf").read_text()
        self.assertIn("set fmri(npts) 100",act); self.assertIn("set fmri(shape10) 3",act)
        self.fake_activation("1")
        self.run_script("code/L1stats.sh","99999","1","VS","--render-only")
        ppi=(subject/"L1_sub-99999_task-trust_ses-01_model-1_type-ppi_seed-VS_run-1.fsf").read_text(); self.assertNotIn("PHYS",ppi)
        self.run_script("code/L1stats.sh","99999","1","dmn","--render-only")
        nppi=(subject/"L1_sub-99999_task-trust_ses-01_model-1_type-nppi-dmn_run-1.fsf").read_text(); self.assertNotRegex(nppi,r'MAINNET|OTHERNET|INPUT[0-9]'); self.assertIn("set fmri(npts) 100",nppi)

    def test_no_miss_shape_and_l1_to_l2_paths_all_types(self):
        self.run_script("code/L1stats.sh","99999","2","0","--render-only")
        text=(self.fsl/"sub-99999/ses-01/L1_sub-99999_task-trust_ses-01_model-1_type-act_run-2.fsf").read_text(); self.assertIn("set fmri(shape10) 10",text)
        for kind,ncopes in (("act",18),("ppi_seed-VS",19),("nppi-dmn",19)):
            for run in ("1","2"):
                feat=self.fsl/"sub-99999/ses-01"/f"L1_task-trust_ses-01_model-1_type-{kind}_run-{run}_sm-5.feat"; (feat/"stats").mkdir(parents=True,exist_ok=True); (feat/"cluster_mask_zstat1.nii.gz").write_bytes(b"x"); (feat/"stats"/f"cope{ncopes}.nii.gz").write_bytes(b"x")
            result=self.run_script("code/L2stats.sh","99999",kind,"--render-only"); self.assertIn("FSLSUB_PARALLEL: 1",result.stdout)
            rendered=(self.fsl/"sub-99999/ses-01"/f"L2_sub-99999_task-trust_ses-01_model-1_type-{kind}.fsf").read_text()
            for run in ("1","2"): self.assertIn(f"L1_task-trust_ses-01_model-1_type-{kind}_run-{run}_sm-5.feat",rendered)
            self.assertNotRegex(rendered,r'INPUT1|INPUT2')


if __name__ == "__main__": unittest.main()
