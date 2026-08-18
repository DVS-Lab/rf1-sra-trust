# Neurodesk teaching notebooks

These notebooks teach the public Trust activation workflow without Linux2. They use only OpenNeuro `ds005123` version `1.1.3` and call the same EV, L1, and L2 scripts/templates as production.

## Neurodesk Play

1. Launch [Neurodesk Play](https://play.neurodesk.org/) and wait for JupyterLab.
2. Open a Terminal.
3. Clone this repository: `git clone https://github.com/DVS-Lab/rf1-sra-trust.git`.
4. Open `rf1-sra-trust/notebooks/`.
5. Execute notebooks 01 → 02 → 03 in order.

The notebooks load exact Neurodesk modules internally: fMRIPrep 25.2.5 and FSL 6.0.7.22. First loads may be slow. fMRIPrep may require several hours, and hosted Play storage should not be assumed permanent. The same notebooks work in local/HPC Neurodesk.

## Contents

- `01_download_and_preprocess.ipynb`: selectively retrieves `sub-10317` anatomical/fieldmap/Trust runs 1–2 and runs focused fMRIPrep.
- `02_first_level_feat.ipynb`: inspects frozen canonical events, calls production EV generation, creates explicitly simplified teaching confounds, and runs both activation L1 models.
- `03_second_level_feat.ipynb`: verifies the L1 path contract and combines runs 1 and 2 with production fixed effects.

The teaching nuisance file is not identical to production: it uses a transparent fMRIPrep-only subset, whereas Linux2 production uses TEDANA-enhanced confounds. Event timing, EV ordering, activation template, contrasts, output naming, and L2 fixed-effects logic remain aligned.

Obtain your own free FreeSurfer license and save it as `~/.license`; no license or credential is embedded. All data/output lives under `~/trust_teaching/`, outside the repository. Do not commit downloaded data or derivatives.
