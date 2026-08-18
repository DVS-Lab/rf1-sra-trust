# Run Record: trust-L1-activation-pilot-sub-10402

- Timestamp: 20260818-193747
- Branch: main
- Commit: c6f0340
- Host: CLA19787.tu.temple.edu
- User: tug87422
- Working directory: `/ZPOOL/data/projects/rf1-sra-trust`
- Raw log: `/ZPOOL/data/projects/rf1-sra-trust/logs/runs/20260818-193747_trust-L1-activation-pilot-sub-10402.log`
- Command exit: 1
- Check exit: skipped
- Summary: COMMAND exit 1; CHECK skipped.

## Command

```bash
bash code/run_L1stats.sh --manifest logs/runlists/L1-pilot.tsv --ppi 0 --jobs 2 --log-dir logs/L1-activation-pilot 
```

## Check

```bash
python3 code/audit_outputs.py --level l1 --manifest logs/runlists/L1-pilot.tsv --type act --output logs/records/L1-act-pilot-completeness.tsv 
```

## Log

```text
RUN START: 20260818-193747
PROJECT_ROOT: /ZPOOL/data/projects/rf1-sra-trust
GIT: main c6f0340
HOST: CLA19787.tu.temple.edu
USER: tug87422
PWD: /ZPOOL/data/projects/rf1-sra-trust
COMMAND: bash code/run_L1stats.sh --manifest logs/runlists/L1-pilot.tsv --ppi 0 --jobs 2 --log-dir logs/L1-activation-pilot 

ERROR: no L1 work units

COMMAND EXIT: 1
CHECK SKIPPED: command failed.
```
