# Trust model-1 FEAT templates

Only `model-1` is active. All templates have FEAT watcher disabled, TR 1.615 s, smoothing 5 mm, FILM prewhitening, and temporal high-pass disabled. L1 volume count is rendered from the input BOLD. L2 is fixed effects (`mixed_yn=3`) across runs 1 and 2.

## Activation EV order

1. `choice_computer`
2. `choice_friend`
3. `choice_stranger`
4. `outcome_computer_defect`
5. `outcome_computer_recip`
6. `outcome_friend_defect`
7. `outcome_friend_recip`
8. `outcome_stranger_defect`
9. `outcome_stranger_recip`
10. `missed_trial` (optional; shape 3 when present, shape 10 when absent)

## Activation contrasts (exact template weights)

| # | Name | EV1–EV10 weights |
|---:|---|---|
| 1 | `c_C` | `1,0,0,0,0,0,0,0,0,0` |
| 2 | `c_F` | `0,1,0,0,0,0,0,0,0,0` |
| 3 | `c_S` | `0,0,1,0,0,0,0,0,0,0` |
| 4 | `C_def` | `0,0,0,1,0,0,0,0,0,0` |
| 5 | `C_rec` | `0,0,0,0,1,0,0,0,0,0` |
| 6 | `F_def` | `0,0,0,0,0,1,0,0,0,0` |
| 7 | `F_rec` | `0,0,0,0,0,0,1,0,0,0` |
| 8 | `S_def` | `0,0,0,0,0,0,0,1,0,0` |
| 9 | `S_rec` | `0,0,0,0,0,0,0,0,1,0` |
| 10 | `rec-def` | `0,0,0,-1,1,-1,1,-1,1,0` |
| 11 | `S+F > C (face)` | `-1,.5,.5,0,0,0,0,0,0,0` |
| 12 | `F > S (rec-def)` | `0,0,0,0,0,-1,1,1,-1,0` |
| 13 | `F > S` | `0,1,-1,0,0,0,0,0,0,0` |
| 14 | `F > C` | `-1,1,0,0,0,0,0,0,0,0` |
| 15 | `S > C` | `-1,0,1,0,0,0,0,0,0,0` |
| 16 | `rec_SocClose` | `0,0,0,0,-1,0,1,0,0,0` |
| 17 | `def_SocClose` | `0,0,0,-1,0,1,0,0,0,0` |
| 18 | `rec-def (SocClose)` | `0,0,0,1,-1,-1,1,0,0,0` |

Weights are transcribed from `L1_task-trust_model-1_type-act.fsf`; names are historical and are not reinterpreted here.

Seed PPI adds the physiological series plus ten task×physiology interaction EVs and a 19th `phys` contrast. Network PPI retains the same 19 contrast definitions while modeling a primary network, its ten interactions, the other focal network, and the remaining network time series. DMN/ECN component roles are described in [masks/README.md](../masks/README.md).

Historical `model-01`, 3–5-run L2, and stale L2 variants are not active. Relevant L3 artifacts remain under `archive/` and have not been scientifically modernized.
