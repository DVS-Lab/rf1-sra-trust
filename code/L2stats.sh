#!/usr/bin/env bash

# Combine Trust runs 1 and 2 within one subject/session using fixed effects.

set -euo pipefail
# Prevent the local fsl_sub backend from multiplying each FEAT unit into a
# machine-sized worker pool. run_L2stats.sh --jobs is the outer control.
export FSLSUB_PARALLEL="${FSLSUB_PARALLEL:-1}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
# shellcheck source=project_config.sh
source "${SCRIPT_DIR}/project_config.sh"
usage() { echo "Usage: L2stats.sh SUBJECT TYPE [--session 01] [--dry-run|--render-only] [--overwrite]" >&2; }
(( $# >= 2 )) || { usage; exit 2; }
sub="$(normalize_subject "$1")"; type="$2"; shift 2
session=01; mode=run; overwrite=0
while (( $# )); do
    case "$1" in
        --session) session="$2"; shift 2 ;; --dry-run) mode=dry-run; shift ;;
        --render-only) mode=render-only; shift ;; --overwrite) overwrite=1; shift ;;
        -h|--help) usage; exit 0 ;; *) echo "ERROR: unknown argument: $1" >&2; exit 2 ;;
    esac
done
session="$(normalize_session "$session")"; ncopes="$(cope_count_for_type "$type")" || { echo "ERROR: unsupported TYPE: $type" >&2; exit 2; }
case "$type" in act) template_type=act ;; ppi_seed-*) template_type=ppi ;; nppi-dmn|nppi-ecn) template_type=nppi ;; esac
smoothing=5
input1="$(l1_output_base "$sub" "$session" 1 "$type" "$smoothing").feat"
input2="$(l1_output_base "$sub" "$session" 2 "$type" "$smoothing").feat"
for input in "$input1" "$input2"; do
    [[ -f "$input/cluster_mask_zstat1.nii.gz" && -f "$input/stats/cope${ncopes}.nii.gz" ]] || { echo "ERROR: complete L1 input required: $input" >&2; exit 1; }
done
output="$(l2_output_base "$sub" "$session" "$type" "$smoothing")"
template="${PROJECT_ROOT}/templates/L2_task-trust_model-1_type-${template_type}.fsf"
subject_output="${FSL_DERIVATIVES_ROOT}/sub-${sub}/ses-${session}"
rendered="${subject_output}/L2_sub-${sub}_task-trust_ses-${session}_model-1_type-${type}.fsf"
[[ -f "$template" ]] || { echo "ERROR: FEAT template not found: $template" >&2; exit 1; }
printf 'L2 plan (fixed effects across Trust runs 1 + 2)\n  run 1: %s\n  run 2: %s\n  output: %s.gfeat\n  FSLSUB_PARALLEL: %s\n' "$input1" "$input2" "$output" "$FSLSUB_PARALLEL"
[[ "$mode" == dry-run ]] && exit 0
gfeat="${output}.gfeat"
if [[ -e "$gfeat" ]]; then
    if (( ! overwrite )); then
        if [[ -f "$gfeat/cope${ncopes}.feat/cluster_mask_zstat1.nii.gz" ]]; then echo "Complete output already exists; skipping: $gfeat"; exit 0; fi
        echo "ERROR: incomplete output exists: $gfeat (use --overwrite)." >&2; exit 1
    fi
    case "$gfeat" in "${FSL_DERIVATIVES_ROOT}"/*) rm -rf -- "$gfeat" ;; *) echo "ERROR: refusing removal outside FSL_DERIVATIVES_ROOT" >&2; exit 1 ;; esac
fi
mkdir -p "$subject_output"
sed_escape() { printf '%s' "$1" | sed 's/[&@\\]/\\&/g'; }
sed -e "s@OUTPUT@$(sed_escape "$output")@g" -e "s@INPUT1@$(sed_escape "$input1")@g" -e "s@INPUT2@$(sed_escape "$input2")@g" "$template" > "$rendered"
if grep -En 'OUTPUT|INPUT1|INPUT2' "$rendered" >/dev/null; then echo "ERROR: unresolved placeholder: $rendered" >&2; exit 1; fi
echo "Rendered: $rendered"
[[ "$mode" == render-only ]] && exit 0
command -v feat >/dev/null || { echo "ERROR: feat is unavailable; load FSL." >&2; exit 1; }
feat "$rendered"
for cope in $(seq "$ncopes"); do
    dir="$gfeat/cope${cope}.feat"
    rm -f -- "$dir/stats/res4d.nii.gz" "$dir/stats/corrections.nii.gz" "$dir/stats/threshac1.nii.gz" "$dir/filtered_func_data.nii.gz" "$dir/var_filtered_func_data.nii.gz"
done
