#!/usr/bin/env bash

# Run activation and one seed-PPI fixed-effects model sequentially per subject-session.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
usage() { echo "Usage: run_L2_activation_ppi.sh --manifest FILE --seed NAME [--jobs N] [--log-dir DIR]" >&2; }
manifest=""; seed=""; jobs=20; log_dir=""
while (( $# )); do
    case "$1" in
        --manifest) manifest="$2"; shift 2 ;;
        --seed) seed="$2"; shift 2 ;;
        --jobs) jobs="$2"; shift 2 ;;
        --log-dir) log_dir="$2"; shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "ERROR: unknown argument: $1" >&2; usage; exit 2 ;;
    esac
done
[[ -f "$manifest" ]] || { echo "ERROR: manifest not found: $manifest" >&2; exit 1; }
[[ -n "$seed" && "$seed" != 0 && "$seed" != act && "$seed" != dmn && "$seed" != ecn ]] || {
    echo "ERROR: --seed must name a seed mask, for example VS" >&2; exit 2;
}
[[ "$jobs" =~ ^[1-9][0-9]*$ ]] || { echo "ERROR: --jobs must be positive" >&2; exit 2; }

units=()
while IFS=$'\t' read -r sub ses extra || [[ -n "${sub:-}" ]]; do
    sub="${sub%$'\r'}"; ses="${ses%$'\r'}"
    [[ "$sub" == subject || -z "$sub" ]] && continue
    [[ -z "${extra:-}" ]] || { echo "ERROR: malformed manifest row" >&2; exit 1; }
    units+=("${sub#sub-}|${ses#ses-}")
done < "$manifest"
(( ${#units[@]} )) || { echo "ERROR: no L2 work units" >&2; exit 1; }
duplicates="$(printf '%s\n' "${units[@]}" | sort | uniq -d)"
[[ -z "$duplicates" ]] || { echo "ERROR: duplicate units" >&2; exit 1; }
[[ -n "$log_dir" ]] && { mkdir -p "$log_dir"; echo "Per-unit logs: $log_dir"; }
printf 'L2 activation+PPI batch plan: %d unit(s), %d job(s), model 1, seed=%s, FSLSUB_PARALLEL=1\n' \
    "${#units[@]}" "$jobs" "$seed"

pids=(); labels=(); logfiles=(); failures=0
wait_oldest() {
    local pid="${pids[0]}" label="${labels[0]}" logfile="${logfiles[0]}"
    if ! wait "$pid"; then
        echo "ERROR: failed L2 activation+PPI unit: $label${logfile:+ (log: $logfile)}" >&2
        failures=$((failures + 1))
    else
        echo "DONE: $label"
    fi
    pids=("${pids[@]:1}"); labels=("${labels[@]:1}"); logfiles=("${logfiles[@]:1}")
}

for unit in "${units[@]}"; do
    IFS='|' read -r sub ses <<< "$unit"
    label="sub-${sub} ses-${ses} act+PPI-${seed}"
    logfile=""
    [[ -n "$log_dir" ]] && logfile="${log_dir}/sub-${sub}_ses-${ses}_act-plus-PPI-${seed}.log"
    echo "START: $label${logfile:+ (log: $logfile)}"
    if [[ -n "$logfile" ]]; then
        (
            echo 'PHASE: activation fixed effects'
            bash "${SCRIPT_DIR}/L2stats.sh" "$sub" act --session "$ses" &&
            echo "PHASE: PPI seed-${seed} fixed effects" &&
            bash "${SCRIPT_DIR}/L2stats.sh" "$sub" "ppi_seed-${seed}" --session "$ses"
        ) >"$logfile" 2>&1 &
    else
        (
            echo 'PHASE: activation fixed effects'
            bash "${SCRIPT_DIR}/L2stats.sh" "$sub" act --session "$ses" &&
            echo "PHASE: PPI seed-${seed} fixed effects" &&
            bash "${SCRIPT_DIR}/L2stats.sh" "$sub" "ppi_seed-${seed}" --session "$ses"
        ) &
    fi
    pids+=("$!"); labels+=("$label"); logfiles+=("$logfile")
    (( ${#pids[@]} >= jobs )) && wait_oldest
done
while (( ${#pids[@]} )); do wait_oldest; done
(( failures == 0 )) || exit 1
