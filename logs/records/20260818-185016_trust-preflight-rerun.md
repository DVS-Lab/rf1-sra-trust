# Run Record: trust-preflight-rerun

- Timestamp: 20260818-185016
- Branch: main
- Commit: 63943cf
- Host: CLA19787.tu.temple.edu
- User: tug87422
- Working directory: `/ZPOOL/data/projects/rf1-sra-trust`
- Raw log: `/ZPOOL/data/projects/rf1-sra-trust/logs/runs/20260818-185016_trust-preflight-rerun.log`
- Command exit: 0
- Check exit: none
- Summary: COMMAND exit 0; CHECK none.

## Command

```bash
bash code/validate_workflow.sh 
```

## Log

```text
RUN START: 20260818-185016
PROJECT_ROOT: /ZPOOL/data/projects/rf1-sra-trust
GIT: main 63943cf
HOST: CLA19787.tu.temple.edu
USER: tug87422
PWD: /ZPOOL/data/projects/rf1-sra-trust
COMMAND: bash code/validate_workflow.sh 

PASS: bash syntax
PASS: Python syntax
PASS: active dependency boundary
test_l1_contract_has_every_cope_and_zstat (test_audit_outputs.AuditOutputTests.test_l1_contract_has_every_cope_and_zstat) ... ok
test_l2_contract_checks_every_cope_directory (test_audit_outputs.AuditOutputTests.test_l2_contract_checks_every_cope_directory) ... ok
test_manifest_requires_run_for_l1 (test_audit_outputs.AuditOutputTests.test_manifest_requires_run_for_l1) ... ok
test_all_types_zero_investment_and_timing_are_preserved (test_event_conversion.EventConversionTests.test_all_types_zero_investment_and_timing_are_preserved) ... ok
test_missing_scientific_category_stops (test_event_conversion.EventConversionTests.test_missing_scientific_category_stops) ... ok
test_overwrite_removes_stale_miss (test_event_conversion.EventConversionTests.test_overwrite_removes_stale_miss) ... ok
test_l1_discovers_actual_runs_and_reports_missing_inputs (test_manifests.ManifestTests.test_l1_discovers_actual_runs_and_reports_missing_inputs) ... ok
test_l2_path_is_session_aware (test_manifests.ManifestTests.test_l2_path_is_session_aware) ... ok
test_public_notebooks_are_structurally_valid_and_aligned (test_notebooks.NotebookTests.test_public_notebooks_are_structurally_valid_and_aligned) ... ok
test_no_miss_shape_and_l1_to_l2_paths_all_types (test_workflow_contract.WorkflowContractTests.test_no_miss_shape_and_l1_to_l2_paths_all_types) ... ok
test_render_activation_seed_and_network_ppi (test_workflow_contract.WorkflowContractTests.test_render_activation_seed_and_network_ppi) ... ok
test_scientific_template_contract (test_workflow_contract.WorkflowContractTests.test_scientific_template_contract) ... ok

----------------------------------------------------------------------
Ran 12 tests in 1.163s

OK

COMMAND EXIT: 0
```
