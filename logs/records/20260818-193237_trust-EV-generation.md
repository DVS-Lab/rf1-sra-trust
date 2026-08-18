# Run Record: trust-EV-generation

- Timestamp: 20260818-193237
- Branch: main
- Commit: c6f0340
- Host: CLA19787.tu.temple.edu
- User: tug87422
- Working directory: `/ZPOOL/data/projects/rf1-sra-trust`
- Raw log: `/ZPOOL/data/projects/rf1-sra-trust/logs/runs/20260818-193237_trust-EV-generation.log`
- Command exit: 0
- Check exit: 0
- Summary: COMMAND exit 0; CHECK 0.

## Command

```bash
bash code/run_gen3colfiles.sh --manifest logs/runlists/L1-ready.tsv --jobs 8 --overwrite 
```

## Check

```bash
bash code/run_L1stats.sh --manifest logs/runlists/L1-ready.tsv --ppi 0 --jobs 1 --dry-run 
```
