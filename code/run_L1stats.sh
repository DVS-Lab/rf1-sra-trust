#!/usr/bin/env bash

# Batch Trust L1 analyses with deterministic bounded shell concurrency.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
usage() { echo "Usage: run_L1stats.sh (--manifest FILE|--subject ID|--sublist FILE) [--session 01] [--runs 1,2] [--ppi 0|SEED|dmn|ecn] [--jobs N] [--dry-run|--render-only] [--overwrite] [--log-dir DIR]" >&2; }
manifest=""; subject=""; sublist=""; session=01; runs_csv=1,2; ppi=0; jobs=20; mode=run; overwrite=0; log_dir=""
while (( $# )); do
    case "$1" in
        --manifest) manifest="$2"; shift 2 ;; --subject) subject="$2"; shift 2 ;;
        --sublist) sublist="$2"; shift 2 ;; --session) session="$2"; shift 2 ;;
        --runs) runs_csv="$2"; shift 2 ;; --ppi) ppi="$2"; shift 2 ;; --jobs) jobs="$2"; shift 2 ;;
        --dry-run) mode=dry-run; shift ;; --render-only) mode=render-only; shift ;;
        --overwrite) overwrite=1; shift ;; --log-dir) log_dir="$2"; shift 2 ;;
        -h|--help) usage; exit 0 ;; *) echo "ERROR: unknown argument: $1" >&2; usage; exit 2 ;;
    esac
done
[[ "$jobs" =~ ^[1-9][0-9]*$ ]] || { echo "ERROR: --jobs must be positive" >&2; exit 2; }
sources=0
[[ -n "$manifest" ]] && sources=$((sources + 1))
[[ -n "$subject" ]] && sources=$((sources + 1))
[[ -n "$sublist" ]] && sources=$((sources + 1))
(( sources == 1 )) || { echo "ERROR: choose exactly one of --manifest, --subject, or --sublist" >&2; exit 2; }
units=()
if [[ -n "$manifest" ]]; then
    [[ -f "$manifest" ]] || { echo "ERROR: manifest not found: $manifest" >&2; exit 1; }
    while IFS=$'\t' read -r sub ses run extra || [[ -n "${sub:-}" ]]; do
        sub="${sub%$'\r'}"; ses="${ses%$'\r'}"; run="${run%$'\r'}"
        [[ "$sub" == subject || -z "$sub" ]] && continue
        [[ -z "${extra:-}" ]] || { echo "ERROR: malformed manifest row" >&2; exit 1; }
        units+=("${sub#sub-}|${ses#ses-}|$run")
    done < "$manifest"
else
    subjects=()
    if [[ -n "$subject" ]]; then subjects+=("${subject#sub-}"); else
        [[ -f "$sublist" ]] || { echo "ERROR: sublist not found: $sublist" >&2; exit 1; }
        while IFS= read -r value || [[ -n "$value" ]]; do value="${value%%#*}"; value="${value//[[:space:]]/}"; [[ -n "$value" ]] && subjects+=("${value#sub-}"); done < "$sublist"
    fi
    IFS=',' read -r -a runs <<< "$runs_csv"
    for sub in "${subjects[@]}"; do for run in "${runs[@]}"; do units+=("$sub|${session#ses-}|$run"); done; done
fi
(( ${#units[@]} )) || { echo "ERROR: no L1 work units" >&2; exit 1; }
duplicates="$(printf '%s\n' "${units[@]}" | sort | uniq -d)"; [[ -z "$duplicates" ]] || { echo "ERROR: duplicate units" >&2; exit 1; }
printf 'L1 batch plan: %d unit(s), %d job(s), model 1, PPI=%s\n' "${#units[@]}" "$jobs" "$ppi"
if [[ -n "$log_dir" && "$mode" != dry-run ]]; then mkdir -p "$log_dir"; echo "Per-unit logs: $log_dir"; fi
pids=(); labels=(); logfiles=(); failures=0
wait_oldest() {
    local pid="${pids[0]}" label="${labels[0]}" logfile="${logfiles[0]}"
    if ! wait "$pid"; then echo "ERROR: failed L1 unit: $label${logfile:+ (log: $logfile)}" >&2; failures=$((failures+1)); else echo "DONE: $label"; fi
    pids=("${pids[@]:1}"); labels=("${labels[@]:1}"); logfiles=("${logfiles[@]:1}")
}
for unit in "${units[@]}"; do
    IFS='|' read -r sub ses run <<< "$unit"; label="sub-${sub} ses-${ses} run-${run}"
    cmd=(bash "${SCRIPT_DIR}/L1stats.sh" "$sub" "$run" "$ppi" --session "$ses")
    [[ "$mode" == dry-run ]] && cmd+=(--dry-run); [[ "$mode" == render-only ]] && cmd+=(--render-only); (( overwrite )) && cmd+=(--overwrite)
    if [[ "$mode" == dry-run ]]; then "${cmd[@]}" || failures=$((failures+1)); continue; fi
    logfile=""; if [[ -n "$log_dir" ]]; then logfile="${log_dir}/sub-${sub}_ses-${ses}_task-trust_run-${run}.log"; echo "START: $label (log: $logfile)"; "${cmd[@]}" >"$logfile" 2>&1 & else echo "START: $label"; "${cmd[@]}" & fi
    pids+=("$!"); labels+=("$label"); logfiles+=("$logfile"); (( ${#pids[@]} >= jobs )) && wait_oldest
done
while (( ${#pids[@]} )); do wait_oldest; done
(( failures == 0 )) || exit 1
