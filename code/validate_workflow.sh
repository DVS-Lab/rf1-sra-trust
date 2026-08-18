#!/usr/bin/env bash

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"; ROOT="$(dirname "$SCRIPT_DIR")"
active=(project_config.sh BIDSto3col.sh gen3colfiles.sh run_gen3colfiles.sh L1stats.sh run_L1stats.sh L2stats.sh run_L2stats.sh run_logged.sh validate_workflow.sh)
for script in "${active[@]}"; do bash -n "${SCRIPT_DIR}/${script}"; done
echo 'PASS: bash syntax'
PYTHONPYCACHEPREFIX="${TMPDIR:-/tmp}/trust-pycache" python3 -m py_compile \
    "${SCRIPT_DIR}/build_L1_manifest.py" \
    "${SCRIPT_DIR}/build_L2_manifest.py" \
    "${SCRIPT_DIR}/trust_qc.py" \
    "${SCRIPT_DIR}/audit_outputs.py"
echo 'PASS: Python syntax'
production=(project_config.sh BIDSto3col.sh gen3colfiles.sh run_gen3colfiles.sh L1stats.sh run_L1stats.sh L2stats.sh run_L2stats.sh run_logged.sh)
if grep -En 'rf1-sra-data|fmriprep-24|confounds_tedana-24|convertTrust_BIDS|run_fmriprep|featwatcher_yn\) 1' "${production[@]/#/${SCRIPT_DIR}/}" "${ROOT}"/templates/L[12]_task-trust_model-1_type-*.fsf; then
    echo 'ERROR: obsolete active dependency or FEAT watcher found' >&2; exit 1
fi
echo 'PASS: active dependency boundary'
PYTHONPYCACHEPREFIX="${TMPDIR:-/tmp}/trust-pycache" python3 -m unittest discover -s "${ROOT}/tests" -v
