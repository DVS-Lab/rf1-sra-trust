# Masks

## Active seed PPI mask

| File | Region | Role | Stored grid | Provenance | Used by |
|---|---|---|---|---|---|
| `seed-VS.nii.gz` | Ventral striatum | Seed PPI example | 57×70×54; 2.7×2.7×2.97 mm | Recovered from this repository’s pre-cleanup history; exact source needs confirmation | `--ppi VS` |

## Active network PPI maps

`melodic-114_smith09_net0.nii.gz` through `net9.nii.gz` are ten continuous Smith-network maps recovered from this repository’s history. Stored grid: 66×78×61; 2.973×2.973×3.22 mm. The historical correlation table identifies component 3 as DMN and component 7 as ECN. Exact upstream image/citation chain needs confirmation.

- `--ppi dmn`: main component 3, other component 7.
- `--ppi ecn`: main component 7, other component 3.
- the other eight component series enter as nuisance EVs in the established nPPI model.

These stored grids do not match current fMRIPrep Trust BOLD. `L1stats.sh` resamples continuous maps with trilinear interpolation onto the exact run grid, writes the result under ignored `derivatives/fsl/resampled_masks/`, and verifies geometry before extraction. The VS seed uses nearest-neighbor interpolation. Tracked sources are never modified.

Result-derived and other historical masks were deliberately not restored to the active tree; they remain recoverable from Git history. Do not add a mask as “active” without documenting its identity, space, grid, provenance, and model use.
