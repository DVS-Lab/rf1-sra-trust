# Run Record: trust-L2-activation-pilot-manifest

- Timestamp: 20260818-204011
- Branch: main
- Commit: 1e87d96
- Host: CLA19787.tu.temple.edu
- User: tug87422
- Working directory: `/ZPOOL/data/projects/rf1-sra-trust`
- Raw log: `/ZPOOL/data/projects/rf1-sra-trust/logs/runs/20260818-204011_trust-L2-activation-pilot-manifest.log`
- Command exit: 0
- Check exit: none
- Summary: COMMAND exit 0; CHECK none.

## Command

```bash
python3 code/build_L2_manifest.py --sublist logs/runlists/L2-pilot-subject.txt --sessions 01 --type act --output logs/runlists/L2-act-pilot-ready.tsv --missing-output logs/runlists/L2-act-pilot-missing.tsv 
```

## Log

```text
RUN START: 20260818-204011
PROJECT_ROOT: /ZPOOL/data/projects/rf1-sra-trust
GIT: main 1e87d96
HOST: CLA19787.tu.temple.edu
USER: tug87422
PWD: /ZPOOL/data/projects/rf1-sra-trust
COMMAND: python3 code/build_L2_manifest.py --sublist logs/runlists/L2-pilot-subject.txt --sessions 01 --type act --output logs/runlists/L2-act-pilot-ready.tsv --missing-output logs/runlists/L2-act-pilot-missing.tsv 

L2 type: act
Ready subject-sessions: 1
Incomplete subject-sessions: 0
Ready manifest: /ZPOOL/data/projects/rf1-sra-trust/logs/runlists/L2-act-pilot-ready.tsv
Missing report: /ZPOOL/data/projects/rf1-sra-trust/logs/runlists/L2-act-pilot-missing.tsv

COMMAND EXIT: 0
```
