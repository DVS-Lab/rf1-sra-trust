# Run Record: trust-L1-activation-PPI-VS-full

- Timestamp: 20260818-210020
- Branch: main
- Commit: 498a319
- Host: CLA19787.tu.temple.edu
- User: tug87422
- Working directory: `/ZPOOL/data/projects/rf1-sra-trust`
- Raw log: `/ZPOOL/data/projects/rf1-sra-trust/logs/runs/20260818-210020_trust-L1-activation-PPI-VS-full.log`
- Command exit: 0
- Check exit: 0
- Summary: CHECK PASSED: all combined L1 activation and PPI-VS units are complete.

## Command

```bash
bash code/run_L1_activation_ppi.sh --manifest logs/runlists/L1-ready.tsv --seed VS --jobs 50 --log-dir logs/L1-activation-PPI-VS-current 
```

## Check

```bash
bash code/audit_L1_activation_ppi.sh --manifest logs/runlists/L1-ready.tsv --seed VS --act-output logs/records/L1-act-completeness.tsv --ppi-output logs/records/L1-PPI-VS-completeness.tsv 
```
