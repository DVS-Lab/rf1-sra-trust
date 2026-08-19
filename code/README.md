# Active code

The production sequence is:

```text
build_L1_manifest.py
  → run_gen3colfiles.sh → gen3colfiles.sh → BIDSto3col.sh
  → run_L1stats.sh → L1stats.sh
  → build_L2_manifest.py
  → run_L2stats.sh → L2stats.sh
```

`project_config.sh` is the single path/naming contract. `trust_qc.py` describes canonical event coverage but never changes inclusion. `audit_outputs.py` verifies every expected L1 or L2 cope/stat product against a manifest, including retained seed/network time-series files for connectivity models. `run_logged.sh` captures ignored raw output and a compact record suitable for Git. Run `validate_workflow.sh` directly for the portable preflight; `make test` remains an optional convenience where Make is installed.

L1 accepts `--ppi 0` for activation, any seed name corresponding to `masks/seed-<name>.nii.gz`, or `dmn`/`ecn` for network PPI. Connectivity requires the corresponding activation FEAT mask. L2 is always fixed effects across Trust runs 1 and 2; `FSLSUB_PARALLEL` defaults to 1 inside `L2stats.sh` so outer `--jobs` remains the concurrency control.

For a combined activation plus seed-PPI production run, `run_L1_activation_ppi.sh` runs those two models sequentially inside each work unit. Its `--jobs` value therefore caps total concurrent FEAT processes rather than multiplying activation and PPI concurrency. `audit_L1_activation_ppi.sh` checks both output families.

The corresponding fixed-effects wrapper is `run_L2_activation_ppi.sh`. It sequences activation and seed-PPI L2 within each paired subject-session, preserves `FSLSUB_PARALLEL=1`, and is checked by `audit_L2_activation_ppi.sh`.

All active commands support `--help`. Prefer manifest-driven production and use `--dry-run` before writing or launching FEAT. Use `--overwrite` only for intentional regeneration.

Files under `archive/` are provenance-only historical SRNDNA/RF1 material. They are excluded from current validation and must not be used as production entry points.
