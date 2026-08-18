#!/usr/bin/env bash

# Goal: Extract ROI mean Z-stat from subject-level FSL outputs
#       Priority: L2 > L1 run-1 > L1 run-2 > fallback to filtered_func_data (run-1)
# Input: ROI mask, sublist, cope #
# Output: One text file per cope, with mean value per subject

# Resolve paths
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
maindir="$(dirname "$scriptdir")"

# Parameters
TASK=trust
MODEL=3
sm=5
N=142
sublist="${maindir}/code/sublist_N142.txt"

for ROI in thr_dACC-thr537_resampled; do
  MASK="${maindir}/masks/${ROI}.nii.gz"

  for TYPE in act; do
    outputdir="${maindir}/derivatives/group_means/${TASK}_${TYPE}_model-${MODEL}_n${N}_zstat"
    mkdir -p "$outputdir"

    for COPENUM in 4 5 8 9; do
      while IFS= read -r subject; do

        # Hardcoded outlier fix — L1 run-1 only
        if [[ $TASK == "trust" && "$subject" =~ ^(10486|10581|10584|10641|10668|10777|10803|10954|11064|11301|11316|11410|11426|11430|11498)$ ]]; then
          files="${maindir}/derivatives/fsl/sub-${subject}/L1_task-${TASK}_model-${MODEL}_type-${TYPE}_run-1_sm-${sm}.feat/stats/zstat${COPENUM}.nii.gz"
          if [ -f "$files" ]; then
            fslmeants -i "$files" -m "$MASK" >> "${outputdir}/${ROI}_${TASK}_type-${TYPE}_zstat-${COPENUM}.txt"
            echo "${subject} (${TASK}) outlier situation dealt with using run-1"
          else
            echo "Outlier subject ${subject}: L1 run-1 file not found — skipping"
          fi
          continue
        fi

        # Standard priority: L2 → L1 run-1 → L1 run-2
        files="${maindir}/derivatives/fsl/sub-${subject}/L2_task-${TASK}_model-${MODEL}_type-${TYPE}_sm-${sm}.gfeat/cope${COPENUM}.feat/stats/zstat1.nii.gz"
        if [ ! -f "$files" ]; then
          files="${maindir}/derivatives/fsl/sub-${subject}/L1_task-${TASK}_model-${MODEL}_type-${TYPE}_run-1_sm-${sm}.feat/stats/zstat${COPENUM}.nii.gz"
        fi
        if [ ! -f "$files" ]; then
          files="${maindir}/derivatives/fsl/sub-${subject}/L1_task-${TASK}_model-${MODEL}_type-${TYPE}_run-2_sm-${sm}.feat/stats/zstat${COPENUM}.nii.gz"
        fi

        if [ -f "$files" ]; then
          fslmeants -i "$files" -m "$MASK" >> "${outputdir}/${ROI}_${TASK}_type-${TYPE}_zstat-${COPENUM}.txt"
          echo "Saved Z-stat mean for subject ${subject} from ${files}"
        else
          # Fallback to functional image (run-1)
          fallback_func="${maindir}/derivatives/fsl/sub-${subject}/L1_task-${TASK}_model-${MODEL}_type-${TYPE}_run-1_sm-${sm}.feat/filtered_func_data.nii.gz"
          if [ -f "$fallback_func" ]; then
            echo "Z-stats missing for subject ${subject}; fallback to filtered_func_data"
            fslmeants -i "$fallback_func" -m "$MASK" >> "${outputdir}/${ROI}_${TASK}_type-${TYPE}_zstat-${COPENUM}_fallback.txt"
            echo "${subject}: used filtered_func_data fallback" >> "${outputdir}/fallback_used.log"
          else
            echo "Check path: fail to locate Z-stats and fallback func for subject ${subject}" | tee -a "${outputdir}/missing_all.log"
          fi
        fi
      done < "$sublist"
    done
  done
done

echo "ROI mean Z-stats and fallbacks saved in: ${outputdir}"

