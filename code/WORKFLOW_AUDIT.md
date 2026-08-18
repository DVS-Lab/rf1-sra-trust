# Workflow audit

Audit performed 2026-08-18 against the current Trust repository plus `rf1-sra-socdoors`, `rf1-sra-ugr`, `rf1-sra-linux2`, and Trust-specific `rf1-betrayal` files.

## Classification and disposition

| Material | Classification | Disposition |
|---|---|---|
| `L1stats.sh`, `L2stats.sh`, batch launchers | Active support | Rebuilt around Linux2 inputs, manifests, session-aware names, bounded jobs, and safe overwrite behavior. |
| Canonical model-1 L1/L2 templates | Current RF1 reference | Retained and normalized; see scientific comparison below. |
| Raw→BIDS, fMRIPrep, IntendedFor, preparation scripts | Historical SRNDNA workflow | Removed from the active tree; preserved in Git history. Linux2 owns these stages. |
| Historical behavioral analyses/covariates | Behavioral analysis | Moved to `code/archive/historical-behavioral/`; unsupported. |
| Extraction, melodic, and tSNR helpers | Historical support | Moved to `code/archive/historical-support/`; unsupported. |
| L3 scripts/templates and added ONES files | Historical/result workflow | Retained under `code/archive/historical-l3/` and `templates/archive/L3/`; not modernized. |
| Editor/application state and generated derivatives | Temporary/generated | Removed or ignored. |

## Scientific comparison

The current Trust activation template and the Trust template in `rf1-betrayal` have the same EV ordering, convolution, orthogonalization, and 18 contrast vectors. Differences were implementation-only: numeric formatting, a hard-coded 280-volume run length versus `NVOLUMES`, and placeholder spelling. The active template adopts dynamic `NVOLUMES` and otherwise preserves the established model.

The old canonical-looking L2 files were stale four-/five-cope variants. The explicit two-run templates contained the correct 18 activation and 19 connectivity cope inputs; these are now the sole active L2 templates. `mixed_yn=3` confirms fixed effects.

The nPPI template retained the established 30-EV construction: 10 task EVs, primary network, 10 task×network interactions, other network, and eight remaining network nuisance series. DMN is Smith component 3; ECN is component 7. Its old TR=2.02, smoothing=6, and fixed 217 volumes were inherited acquisition/runtime settings, not alternative scientific definitions; these now match RF1 Trust (TR=1.615, smoothing=5, dynamic volume count). Its 19 contrast vectors are unchanged.

## Masks and geometry

The ten `melodic-114_smith09_net*.nii.gz` maps and `seed-VS.nii.gz` were recovered from this repository’s own history, not copied from the cross-task betrayal project. Their native grids do not match current fMRIPrep MNI Trust BOLD. `L1stats.sh` therefore resamples them deterministically into ignored derivatives on the exact run grid (trilinear for continuous network maps; nearest-neighbor for the VS seed) and verifies the resulting spatial dimensions/voxel sizes before extraction. Original tracked masks are never overwritten.

Mask identity is based on the historical implementation and correlation table: component 3=DMN and component 7=ECN. More detailed provenance for the seed remains to be confirmed; this is stated rather than inferred.

## Remaining production checks

The local development clone has no `/ZPOOL` dataset. Before a full run, use `trust_qc.py` on Linux2’s canonical events to confirm that every estimable run contains all nine non-miss model categories. The active generator intentionally stops and reports a missing category; it never invents a zero-investment outcome or silently changes a participant’s design.
