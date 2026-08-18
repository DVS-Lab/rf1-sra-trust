#!/bin/bash

maindir=/gpfs/scratch/tug87422/smithlab-shared/rf1-sra-trust
templatedir=${maindir}/templates
scriptdir=${maindir}/code
logdir=${maindir}/logs
maskdir=${maindir}/masks
mkdir -p $logdir
# Defaults to ppi; note that you never need to input ppi mask name, will go through all seed- files in /masks
mode=${1:-"ppi"}

if [[ "$mode" == "act" ]]; then
  covariates=($(basename -a ${templatedir}/L3_task-ugr_model-3_type-act_group-*n128_flame1.fsf | \
    sed -E 's/L3_task-ugr_model-3_type-act_group-(.*)_n128_flame1.fsf/\1/'))

  for covariate in "${covariates[@]}"; do
    jobname="L3stats-${covariate}"
    logprefix="${logdir}/${jobname}"
    qsub -v task="ugr",model="3",covariate="${covariate}",REPLACEME="act",ROI="act" \
         -N "$jobname" \
         -o "${logprefix}.o" \
         -e "${logprefix}.e" \
         ${scriptdir}/L3stats-hpc_ONES.sh 
  done

elif [[ "$mode" == "ppi" ]]; then
  covariates=($(basename -a ${templatedir}/L3_task-ugr_model-3_type-ppi_group-*n128_flame1.fsf | \
    sed -E 's/L3_task-ugr_model-3_type-ppi_group-(.*)_n128_flame1.fsf/\1/'))

  for mask in ${maskdir}/thr_seed-*.nii.gz; do
    ROI=$(basename "$mask" | sed 's/^thr_seed-//' | sed 's/\.nii\.gz$//')

    for covariate in "${covariates[@]}"; do
      jobname="L3stats-${covariate}-${ROI}"
      logprefix="${logdir}/${jobname}"
      qsub -v task="ugr",model=3,covariate="${covariate}",REPLACEME="ppi",ROI="${ROI}" \
           -N "$jobname" \
           -o "${logprefix}.o" \
           -e "${logprefix}.e" \
           ${scriptdir}/L3stats-hpc_ppi.sh
    done
  done

else
  echo "Invalid mode: $mode"
  echo "Usage: bash run_L3stats-hpc.sh act   OR   bash run_L3stats-hpc.sh ppi"
  exit 1
fi

