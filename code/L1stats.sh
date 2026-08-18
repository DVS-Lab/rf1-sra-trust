#!/usr/bin/env bash

# Render and run one Trust model-1 first-level FEAT analysis.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
# shellcheck source=project_config.sh
source "${SCRIPT_DIR}/project_config.sh"

usage() {
    cat >&2 <<'EOF'
Usage: L1stats.sh SUBJECT RUN PPI [options]

PPI is 0/act, a seed name matching masks/seed-<name>.nii.gz, dmn, or ecn.

Options:
  --session ID       BIDS session (default: 01)
  --bold FILE        Override canonical fMRIPrep BOLD (testing/teaching)
  --confounds FILE   Override canonical TEDANA-enhanced confounds
  --dry-run          Validate inputs and print paths without writing
  --render-only      Render and validate the .fsf without running FEAT
  --overwrite        Replace an incomplete or complete generated FEAT output
EOF
}

(( $# >= 3 )) || { usage; exit 2; }
sub="$(normalize_subject "$1")"; run="$2"; ppi="$3"; shift 3
session="01"; bold_override=""; confounds_override=""; mode=run; overwrite=0
while (( $# )); do
    case "$1" in
        --session) session="$2"; shift 2 ;;
        --bold) bold_override="$2"; shift 2 ;;
        --confounds) confounds_override="$2"; shift 2 ;;
        --dry-run) mode=dry-run; shift ;;
        --render-only) mode=render-only; shift ;;
        --overwrite) overwrite=1; shift ;;
        -h|--help) usage; exit 0 ;;
        *) echo "ERROR: unknown argument: $1" >&2; usage; exit 2 ;;
    esac
done
session="$(normalize_session "$session")"; smoothing=5
type="$(analysis_type_from_ppi "$ppi")"
ncopes="$(cope_count_for_type "$type")" || { echo "ERROR: unsupported type: $type" >&2; exit 2; }
subject_output="${FSL_DERIVATIVES_ROOT}/sub-${sub}/ses-${session}"
output="$(l1_output_base "$sub" "$session" "$run" "$type" "$smoothing")"
stem="sub-${sub}_ses-${session}_task-trust_run-${run}"
data="${bold_override:-${FMRIPREP_ROOT}/sub-${sub}/ses-${session}/func/${stem}_part-mag_space-MNI152NLin6Asym_desc-preproc_bold.nii.gz}"
confounds="${confounds_override:-${CONFOUNDS_ROOT}/sub-${sub}/${stem}_desc-TedanaPlusConfounds.tsv}"
ev_prefix="$(trust_ev_prefix "$sub" "$session" "$run")"
missed_ev="${ev_prefix}_missed_trial.txt"; shape_missed=10
[[ -s "$missed_ev" ]] && shape_missed=3
required_evs=(
    choice_computer choice_friend choice_stranger
    outcome_computer_defect outcome_computer_recip
    outcome_friend_defect outcome_friend_recip
    outcome_stranger_defect outcome_stranger_recip
)
for ev in "${required_evs[@]}"; do
    [[ -s "${ev_prefix}_${ev}.txt" ]] || { echo "ERROR: required EV missing or empty: ${ev_prefix}_${ev}.txt" >&2; exit 1; }
done
[[ -f "$data" ]] || { echo "ERROR: BOLD input not found: $data" >&2; exit 1; }
[[ -s "$confounds" ]] || { echo "ERROR: confounds missing or empty: $confounds" >&2; exit 1; }

case "$type" in
    act) template="${PROJECT_ROOT}/templates/L1_task-trust_model-1_type-act.fsf" ;;
    ppi_seed-*) template="${PROJECT_ROOT}/templates/L1_task-trust_model-1_type-ppi.fsf" ;;
    nppi-dmn|nppi-ecn) template="${PROJECT_ROOT}/templates/L1_task-trust_model-1_type-nppi.fsf" ;;
esac
[[ -f "$template" ]] || { echo "ERROR: FEAT template not found: $template" >&2; exit 1; }
rendered="${subject_output}/L1_sub-${sub}_task-trust_ses-${session}_model-1_type-${type}_run-${run}.fsf"
printf 'L1 plan\n  BOLD: %s\n  confounds: %s\n  EV prefix: %s\n  template: %s\n  output: %s.feat\n' \
    "$data" "$confounds" "$ev_prefix" "$template" "$output"
[[ "$type" == ppi_seed-* ]] && printf '  seed: %s\n' "${PROJECT_ROOT}/masks/seed-${type#ppi_seed-}.nii.gz"
[[ "$type" == nppi-* ]] && printf '  network: %s (Smith component %s; other component %s)\n' \
    "${type#nppi-}" "$([[ "$type" == nppi-dmn ]] && echo 3 || echo 7)" "$([[ "$type" == nppi-dmn ]] && echo 7 || echo 3)"
if [[ "$type" == ppi_seed-* ]]; then
    [[ -f "${PROJECT_ROOT}/masks/seed-${type#ppi_seed-}.nii.gz" ]] || { echo "ERROR: seed mask not found" >&2; exit 1; }
    [[ -f "$(l1_output_base "$sub" "$session" "$run" act "$smoothing").feat/mask.nii.gz" ]] || { echo "ERROR: activation FEAT mask required before PPI" >&2; exit 1; }
elif [[ "$type" == nppi-* ]]; then
    [[ -f "$(l1_output_base "$sub" "$session" "$run" act "$smoothing").feat/mask.nii.gz" ]] || { echo "ERROR: activation FEAT mask required before nPPI" >&2; exit 1; }
    for net in {0..9}; do [[ -f "${PROJECT_ROOT}/masks/melodic-114_smith09_net${net}.nii.gz" ]] || { echo "ERROR: network mask missing: net${net}" >&2; exit 1; }; done
fi
[[ "$mode" == dry-run ]] && exit 0

for command in fslnvols; do command -v "$command" >/dev/null || { echo "ERROR: $command is unavailable; load FSL." >&2; exit 1; }; done
nvolumes="$(fslnvols "$data")"
[[ "$nvolumes" =~ ^[0-9]+$ ]] || { echo "ERROR: invalid BOLD volume count: $nvolumes" >&2; exit 1; }
feat_dir="${output}.feat"
if [[ -e "$feat_dir" ]]; then
    if (( ! overwrite )); then
        if [[ -f "$feat_dir/cluster_mask_zstat1.nii.gz" && -f "$feat_dir/stats/cope${ncopes}.nii.gz" ]]; then
            echo "Complete output already exists; skipping: $feat_dir"; exit 0
        fi
        echo "ERROR: incomplete output exists: $feat_dir (use --overwrite)." >&2; exit 1
    fi
    case "$feat_dir" in
        "${FSL_DERIVATIVES_ROOT}"/*) rm -rf -- "$feat_dir" ;;
        *) echo "ERROR: refusing to remove output outside FSL_DERIVATIVES_ROOT: $feat_dir" >&2; exit 1 ;;
    esac
fi
mkdir -p "$subject_output"

geometry_signature() {
    local image="$1" key
    for key in dim1 dim2 dim3 pixdim1 pixdim2 pixdim3; do printf '%s ' "$(fslval "$image" "$key")"; done
}

prepare_mask() {
    local source="$1" label="$2" interpolation="$3" cached ref
    [[ -f "$source" ]] || { echo "ERROR: mask not found: $source" >&2; return 1; }
    for command in fslval; do command -v "$command" >/dev/null || { echo "ERROR: $command is unavailable; load FSL." >&2; return 1; }; done
    if [[ "$(geometry_signature "$source")" == "$(geometry_signature "$data")" ]]; then
        printf '%s\n' "$source"; return 0
    fi
    for command in fslroi flirt; do command -v "$command" >/dev/null || { echo "ERROR: $command is needed to resample $label." >&2; return 1; }; done
    cached="${FSL_DERIVATIVES_ROOT}/resampled_masks/sub-${sub}/ses-${session}/${stem}_mask-${label}.nii.gz"
    mkdir -p "$(dirname "$cached")"
    if [[ -f "$cached" && ! "$source" -nt "$cached" && "$(geometry_signature "$cached")" == "$(geometry_signature "$data")" ]]; then
        printf '%s\n' "$cached"; return 0
    fi
    ref="${cached%.nii.gz}_reference.nii.gz"
    fslroi "$data" "$ref" 0 1
    flirt -in "$source" -ref "$ref" -applyxfm -usesqform -interp "$interpolation" -out "$cached"
    rm -f -- "$ref"
    [[ "$(geometry_signature "$cached")" == "$(geometry_signature "$data")" ]] || {
        echo "ERROR: resampled mask still does not match BOLD geometry: $cached" >&2; return 1;
    }
    echo "Resampled mask geometry: $source -> $cached" >&2
    printf '%s\n' "$cached"
}

sed_escape() { printf '%s' "$1" | sed 's/[&@\\]/\\&/g'; }
sed_args=(
    -e "s@OUTPUT@$(sed_escape "$output")@g"
    -e "s@DATA@$(sed_escape "$data")@g"
    -e "s@EVDIR@$(sed_escape "$ev_prefix")@g"
    -e "s@MISSED_TRIAL@$(sed_escape "$missed_ev")@g"
    -e "s@SHAPE_EV@${shape_missed}@g"
    -e "s@SMOOTH@${smoothing}@g"
    -e "s@CONFOUNDEVS@$(sed_escape "$confounds")@g"
    -e "s@NVOLUMES@${nvolumes}@g"
)

activation="$(l1_output_base "$sub" "$session" "$run" act "$smoothing").feat"
if [[ "$type" == ppi_seed-* ]]; then
    [[ -f "$activation/mask.nii.gz" ]] || { echo "ERROR: activation FEAT mask required before PPI: $activation" >&2; exit 1; }
    command -v fslmeants >/dev/null || { echo "ERROR: fslmeants is unavailable; load FSL." >&2; exit 1; }
    seed="${type#ppi_seed-}"
    mask="$(prepare_mask "${PROJECT_ROOT}/masks/seed-${seed}.nii.gz" "seed-${seed}" nearestneighbour)"
    phys="${subject_output}/ts_task-trust_ses-${session}_mask-${seed}_run-${run}.txt"
    fslmeants -i "$data" -o "$phys" -m "$mask"
    [[ "$(awk 'NF {n++} END {print n+0}' "$phys")" -eq "$nvolumes" ]] || { echo "ERROR: seed time series length mismatch: $phys" >&2; exit 1; }
    sed_args+=( -e "s@PHYS@$(sed_escape "$phys")@g" )
elif [[ "$type" == nppi-* ]]; then
    [[ -f "$activation/mask.nii.gz" ]] || { echo "ERROR: activation FEAT mask required before nPPI: $activation" >&2; exit 1; }
    command -v fsl_glm >/dev/null || { echo "ERROR: fsl_glm is unavailable; load FSL." >&2; exit 1; }
    series=()
    for net in {0..9}; do
        network_mask="$(prepare_mask "${PROJECT_ROOT}/masks/melodic-114_smith09_net${net}.nii.gz" "smith09-net${net}" trilinear)"
        ts="${subject_output}/ts_task-trust_ses-${session}_network-smith09-net${net}_run-${run}.txt"
        fsl_glm -i "$data" -d "$network_mask" -o "$ts" --demean -m "$activation/mask.nii.gz"
        [[ "$(awk 'NF {n++} END {print n+0}' "$ts")" -eq "$nvolumes" ]] || { echo "ERROR: network time series length mismatch: $ts" >&2; exit 1; }
        series+=("$ts")
    done
    if [[ "$type" == nppi-dmn ]]; then mainnet="${series[3]}"; othernet="${series[7]}"; else mainnet="${series[7]}"; othernet="${series[3]}"; fi
    sed_args+=( -e "s@MAINNET@$(sed_escape "$mainnet")@g" -e "s@OTHERNET@$(sed_escape "$othernet")@g" )
    for net in 0 1 2 4 5 6 8 9; do sed_args+=( -e "s@INPUT${net}@$(sed_escape "${series[$net]}")@g" ); done
fi

sed "${sed_args[@]}" "$template" > "$rendered"
if grep -En 'OUTPUT|DATA|EVDIR|MISSED_TRIAL|SHAPE_EV|SMOOTH|CONFOUNDEVS|NVOLUMES|PHYS|MAINNET|OTHERNET|INPUT[0-9]' "$rendered" >/dev/null; then
    echo "ERROR: unresolved placeholder in rendered template: $rendered" >&2; exit 1
fi
echo "Rendered: $rendered"
[[ "$mode" == render-only ]] && exit 0
command -v feat >/dev/null || { echo "ERROR: feat is unavailable; load FSL." >&2; exit 1; }
feat "$rendered"
[[ -n "${FSLDIR:-}" && -f "${FSLDIR}/etc/flirtsch/ident.mat" ]] || { echo "ERROR: FSLDIR/ident.mat unavailable." >&2; exit 1; }
mkdir -p "$feat_dir/reg"
ln -sfn "${FSLDIR}/etc/flirtsch/ident.mat" "$feat_dir/reg/example_func2standard.mat"
ln -sfn "${FSLDIR}/etc/flirtsch/ident.mat" "$feat_dir/reg/standard2example_func.mat"
ln -sfn "$feat_dir/mean_func.nii.gz" "$feat_dir/reg/standard.nii.gz"
rm -f -- "$feat_dir/stats/res4d.nii.gz" "$feat_dir/stats/corrections.nii.gz" \
    "$feat_dir/stats/threshac1.nii.gz" "$feat_dir/filtered_func_data.nii.gz"
