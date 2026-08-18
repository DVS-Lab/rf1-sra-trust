#!/usr/bin/env bash

# Generate Trust EVs for the exact units in an L1 manifest.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
usage() { echo "Usage: run_gen3colfiles.sh --manifest FILE [--jobs N] [--dry-run] [--overwrite]" >&2; }
manifest=""; jobs=8; dry_run=0; overwrite=0
while (( $# )); do
    case "$1" in
        --manifest) manifest="$2"; shift 2 ;;
        --jobs) jobs="$2"; shift 2 ;;
        --dry-run) dry_run=1; shift ;;
        --overwrite) overwrite=1; shift ;;
        -h|--help) usage; exit 0 ;;
        *) echo "ERROR: unknown argument: $1" >&2; usage; exit 2 ;;
    esac
done
[[ -f "$manifest" ]] || { echo "ERROR: manifest not found: $manifest" >&2; exit 1; }
[[ "$jobs" =~ ^[1-9][0-9]*$ ]] || { echo "ERROR: --jobs must be positive" >&2; exit 2; }
units=()
while IFS=$'\t' read -r sub ses run extra || [[ -n "${sub:-}" ]]; do
    sub="${sub%$'\r'}"; ses="${ses%$'\r'}"; run="${run%$'\r'}"
    [[ "$sub" == subject || -z "$sub" ]] && continue
    [[ -z "${extra:-}" ]] || { echo "ERROR: malformed L1 manifest row" >&2; exit 1; }
    units+=("${sub#sub-}|${ses#ses-}|$run")
done < "$manifest"
(( ${#units[@]} )) || { echo "ERROR: manifest contains no units" >&2; exit 1; }
duplicates="$(printf '%s\n' "${units[@]}" | sort | uniq -d)"
[[ -z "$duplicates" ]] || { echo "ERROR: duplicate manifest units:" >&2; echo "$duplicates" >&2; exit 1; }
printf 'EV batch plan: %d unit(s), %d job(s), manifest %s\n' "${#units[@]}" "$jobs" "$manifest"

pids=(); labels=(); failures=0
wait_oldest() {
    local pid="${pids[0]}" label="${labels[0]}"
    if ! wait "$pid"; then echo "ERROR: failed EV unit: $label" >&2; failures=$((failures+1)); fi
    pids=("${pids[@]:1}"); labels=("${labels[@]:1}")
}
for unit in "${units[@]}"; do
    IFS='|' read -r sub ses run <<< "$unit"
    cmd=(bash "${SCRIPT_DIR}/gen3colfiles.sh" --subject "$sub" --session "$ses" --run "$run")
    (( dry_run )) && cmd+=(--dry-run)
    (( overwrite )) && cmd+=(--overwrite)
    if (( dry_run )); then "${cmd[@]}" || failures=$((failures+1)); continue; fi
    echo "START: sub-${sub} ses-${ses} run-${run}"
    "${cmd[@]}" & pids+=("$!"); labels+=("sub-${sub} ses-${ses} run-${run}")
    (( ${#pids[@]} >= jobs )) && wait_oldest
done
while (( ${#pids[@]} )); do wait_oldest; done
(( failures == 0 )) || exit 1
