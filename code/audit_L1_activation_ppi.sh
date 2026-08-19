#!/usr/bin/env bash

# Audit both halves of a combined activation plus seed-PPI L1 launch.

set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
usage() { echo "Usage: audit_L1_activation_ppi.sh --manifest FILE --seed NAME --act-output FILE --ppi-output FILE" >&2; }
manifest=""; seed=""; act_output=""; ppi_output=""
while (( $# )); do
    case "$1" in
        --manifest) manifest="$2"; shift 2 ;;
        --seed) seed="$2"; shift 2 ;;
        --act-output) act_output="$2"; shift 2 ;;
        --ppi-output) ppi_output="$2"; shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "ERROR: unknown argument: $1" >&2; usage; exit 2 ;;
    esac
done
[[ -n "$manifest" && -n "$seed" && -n "$act_output" && -n "$ppi_output" ]] || { usage; exit 2; }

failed=0
python3 "${SCRIPT_DIR}/audit_outputs.py" \
    --level l1 --manifest "$manifest" --type act --output "$act_output" || failed=1
python3 "${SCRIPT_DIR}/audit_outputs.py" \
    --level l1 --manifest "$manifest" --type "ppi_seed-${seed}" --output "$ppi_output" || failed=1

if (( failed )); then
    echo "CHECK FAILED: combined L1 activation and PPI-${seed} audit found incomplete units."
    exit 1
fi
echo "CHECK PASSED: all combined L1 activation and PPI-${seed} units are complete."
