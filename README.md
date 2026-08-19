# RF1-SRA Trust

This is the authoritative downstream repository for RF1-SRA Trust Game fMRI analysis. It converts canonical BIDS events to FSL EVs, runs the established model-1 activation/seed-PPI/network-PPI models, and combines Trust runs 1 and 2 with fixed effects.

## Reproducibility boundary

Production input comes only from [`rf1-sra-linux2`](https://github.com/DVS-Lab/rf1-sra-linux2):

- canonical `task-trust` BIDS events;
- fMRIPrep MNI-space BOLD images;
- TEDANA-enhanced FSL confounds.

This repository does not own raw logs, DICOM conversion, BIDS construction, fMRIPrep, TEDANA, or confound construction. Generated EVs and FEAT outputs live under ignored `derivatives/fsl/`. The frozen public teaching workflow uses OpenNeuro `ds005123`, version `1.1.3`.

## Pipeline

```text
Linux2 canonical events ──> FSL three-column EVs ──> L1 model-1
Linux2 fMRIPrep BOLD ──────────────────────────────> activation / seed PPI / nPPI
Linux2 TEDANA confounds ───────────────────────────> runs 1 + 2 ──> L2 fixed effects
```

The established activation model has 10 task EVs and 18 contrasts. Seed PPI and DMN/ECN nPPI each retain 19 contrasts. See [templates/README.md](templates/README.md) for the exact model contract.

## Internal quick start

On Linux2:

```bash
cd /ZPOOL/data/projects/rf1-sra-trust
git pull --ff-only origin main
bash code/validate_workflow.sh

python3 code/build_L1_manifest.py \
  --output logs/runlists/L1-ready.tsv \
  --missing-output logs/runlists/L1-missing.tsv

bash code/run_logged.sh --label trust-EVs -- \
  bash code/run_gen3colfiles.sh \
    --manifest logs/runlists/L1-ready.tsv --jobs 8

bash code/run_logged.sh --label trust-L1-activation -- \
  bash code/run_L1stats.sh \
    --manifest logs/runlists/L1-ready.tsv --ppi 0 --jobs 50 \
    --log-dir logs/L1-activation-current \
  --check python3 code/audit_outputs.py \
    --level l1 --manifest logs/runlists/L1-ready.tsv --type act \
    --output logs/records/L1-act-completeness.tsv
```

Build L2 readiness only after both L1 runs are complete:

```bash
python3 code/build_L2_manifest.py --type act \
  --output logs/runlists/L2-act-ready.tsv \
  --missing-output logs/runlists/L2-act-missing.tsv

bash code/run_logged.sh --label trust-L2-activation -- \
  bash code/run_L2stats.sh \
    --manifest logs/runlists/L2-act-ready.tsv --type act --jobs 20 \
    --log-dir logs/L2-activation-current \
  --check python3 code/audit_outputs.py \
    --level l2 --manifest logs/runlists/L2-act-ready.tsv --type act \
    --output logs/records/L2-act-completeness.tsv
```

For connectivity, run activation first, then use `--ppi VS`, `--ppi dmn`, or `--ppi ecn`. Build the matching L2 manifest with `--type ppi_seed-VS`, `nppi-dmn`, or `nppi-ecn`.

To launch activation and one seed-PPI model together without doubling concurrency, use `code/run_L1_activation_ppi.sh`. Each run-level worker completes activation before its matching PPI model; `--jobs 50` therefore means at most 50 simultaneous FEAT processes total.

For paired fixed effects, `code/run_L2_activation_ppi.sh` provides the same sequencing at the subject-session level. `--jobs 20` means at most 20 concurrent L2 models, while `L2stats.sh` keeps within-model FSL submission serial.

## Public teaching quick start

Open [notebooks/README.md](notebooks/README.md) and run notebooks 01 → 02 → 03 in Neurodesk. They download only one public participant’s Trust files and call the same production scripts/templates used above.

## Repository layout

- `code/`: active manifest, EV, L1/L2, QC, completeness-audit, validation, and logging tools; historical material is under `code/archive/`.
- `templates/`: sole active model-1 FEAT templates; historical L3 materials are archived.
- `masks/`: the retained VS seed and Smith-network maps with provenance/geometry notes.
- `notebooks/`: public Neurodesk teaching workflow.
- `tests/`: lightweight scientific and path-contract tests.
- `logs/records/`: compact Git-trackable run records; raw logs remain ignored.

## Historical notes

This repository originated as an SRNDNA Trust repository and previously mixed preprocessing, behavioral conversion, analysis, extraction, and presentation assets. The current workflow is intentionally narrower. Historical behavioral/support code and L3 material remain clearly archived and are not production-supported. See [code/WORKFLOW_AUDIT.md](code/WORKFLOW_AUDIT.md).
