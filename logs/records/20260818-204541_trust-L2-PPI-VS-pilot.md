# Run Record: trust-L2-PPI-VS-pilot

- Timestamp: 20260818-204541
- Branch: main
- Commit: 1e87d96
- Host: CLA19787.tu.temple.edu
- User: tug87422
- Working directory: `/ZPOOL/data/projects/rf1-sra-trust`
- Raw log: `/ZPOOL/data/projects/rf1-sra-trust/logs/runs/20260818-204541_trust-L2-PPI-VS-pilot.log`
- Command exit: 0
- Check exit: 0
- Summary: CHECK PASSED: all 1 L2 ppi_seed-VS unit(s) are complete.

## Command

```bash
bash code/run_L2stats.sh --manifest logs/runlists/L2-PPI-VS-pilot-ready.tsv --type ppi_seed-VS --jobs 1 --log-dir logs/L2-PPI-VS-pilot 
```

## Check

```bash
python3 code/audit_outputs.py --level l2 --manifest logs/runlists/L2-PPI-VS-pilot-ready.tsv --type ppi_seed-VS --output logs/records/L2-PPI-VS-pilot-completeness.tsv 
```

## Log

```text
RUN START: 20260818-204541
PROJECT_ROOT: /ZPOOL/data/projects/rf1-sra-trust
GIT: main 1e87d96
HOST: CLA19787.tu.temple.edu
USER: tug87422
PWD: /ZPOOL/data/projects/rf1-sra-trust
COMMAND: bash code/run_L2stats.sh --manifest logs/runlists/L2-PPI-VS-pilot-ready.tsv --type ppi_seed-VS --jobs 1 --log-dir logs/L2-PPI-VS-pilot 

L2 batch plan: 1 unit(s), 1 job(s), model 1, type=ppi_seed-VS
Per-unit logs: logs/L2-PPI-VS-pilot
START: sub-10402 ses-01 type-ppi_seed-VS (log: logs/L2-PPI-VS-pilot/sub-10402_ses-01_type-ppi_seed-VS.log)
DONE: sub-10402 ses-01 type-ppi_seed-VS

COMMAND EXIT: 0

CHECK COMMAND: python3 code/audit_outputs.py --level l2 --manifest logs/runlists/L2-PPI-VS-pilot-ready.tsv --type ppi_seed-VS --output logs/records/L2-PPI-VS-pilot-completeness.tsv 

Manifest units checked: 1
Fully complete L2 units: 1
Incomplete L2 units: 0
Completeness report: /ZPOOL/data/projects/rf1-sra-trust/logs/records/L2-PPI-VS-pilot-completeness.tsv
CHECK PASSED: all 1 L2 ppi_seed-VS unit(s) are complete.

CHECK EXIT: 0
```
