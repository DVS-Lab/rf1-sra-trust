#!/usr/bin/env bash

# Batch Trust two-run L2 fixed-effects analyses.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
usage() { echo "Usage: run_L2stats.sh (--manifest FILE|--subject ID) --type TYPE [--session 01] [--jobs N] [--dry-run|--render-only] [--overwrite] [--log-dir DIR]" >&2; }
manifest=""; subject=""; session=01; type=""; jobs=20; mode=run; overwrite=0; log_dir=""
while (( $# )); do
    case "$1" in
        --manifest) manifest="$2"; shift 2 ;; --subject) subject="$2"; shift 2 ;; --session) session="$2"; shift 2 ;;
        --type) type="$2"; shift 2 ;; --jobs) jobs="$2"; shift 2 ;; --dry-run) mode=dry-run; shift ;;
        --render-only) mode=render-only; shift ;; --overwrite) overwrite=1; shift ;; --log-dir) log_dir="$2"; shift 2 ;;
        -h|--help) usage; exit 0 ;; *) echo "ERROR: unknown argument: $1" >&2; usage; exit 2 ;;
    esac
done
case "$type" in act|ppi_seed-?*|nppi-dmn|nppi-ecn) ;; *) echo "ERROR: invalid --type" >&2; exit 2 ;; esac
[[ "$jobs" =~ ^[1-9][0-9]*$ ]] || { echo "ERROR: --jobs must be positive" >&2; exit 2; }
[[ -n "$manifest" || -n "$subject" ]] && [[ -z "$manifest" || -z "$subject" ]] || { echo "ERROR: choose one of --manifest or --subject" >&2; exit 2; }
units=()
if [[ -n "$manifest" ]]; then
    [[ -f "$manifest" ]] || { echo "ERROR: manifest not found: $manifest" >&2; exit 1; }
    while IFS=$'\t' read -r sub ses extra || [[ -n "${sub:-}" ]]; do sub="${sub%$'\r'}"; ses="${ses%$'\r'}"; [[ "$sub" == subject || -z "$sub" ]] && continue; [[ -z "${extra:-}" ]] || { echo "ERROR: malformed manifest row" >&2; exit 1; }; units+=("${sub#sub-}|${ses#ses-}"); done < "$manifest"
else units+=("${subject#sub-}|${session#ses-}"); fi
printf 'L2 batch plan: %d unit(s), %d job(s), model 1, type=%s\n' "${#units[@]}" "$jobs" "$type"
if [[ -n "$log_dir" && "$mode" != dry-run ]]; then mkdir -p "$log_dir"; echo "Per-unit logs: $log_dir"; fi
pids=(); labels=(); logfiles=(); failures=0
wait_oldest() { local pid="${pids[0]}" label="${labels[0]}" logfile="${logfiles[0]}"; if ! wait "$pid"; then echo "ERROR: failed L2 unit: $label${logfile:+ (log: $logfile)}" >&2; failures=$((failures+1)); else echo "DONE: $label"; fi; pids=("${pids[@]:1}"); labels=("${labels[@]:1}"); logfiles=("${logfiles[@]:1}"); }
for unit in "${units[@]}"; do
    IFS='|' read -r sub ses <<< "$unit"; label="sub-${sub} ses-${ses} type-${type}"; cmd=(bash "${SCRIPT_DIR}/L2stats.sh" "$sub" "$type" --session "$ses")
    [[ "$mode" == dry-run ]] && cmd+=(--dry-run); [[ "$mode" == render-only ]] && cmd+=(--render-only); (( overwrite )) && cmd+=(--overwrite)
    if [[ "$mode" == dry-run ]]; then "${cmd[@]}" || failures=$((failures+1)); continue; fi
    logfile=""; if [[ -n "$log_dir" ]]; then logfile="${log_dir}/sub-${sub}_ses-${ses}_type-${type}.log"; echo "START: $label (log: $logfile)"; "${cmd[@]}" >"$logfile" 2>&1 & else echo "START: $label"; "${cmd[@]}" & fi
    pids+=("$!"); labels+=("$label"); logfiles+=("$logfile"); (( ${#pids[@]} >= jobs )) && wait_oldest
done
while (( ${#pids[@]} )); do wait_oldest; done
(( failures == 0 )) || exit 1
