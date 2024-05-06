#!/bin/bash

# Set the number of cores to use
NCORES=20

# Ensure paths are correct irrespective from where user runs the script
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
datadir=/ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep
tasks=("trust" "ugr" "sharedreward")

# Print header
echo -e "sub\t mean_stan_run1\t mean_stan_run2\t mean_nat_run1\t mean_nat_run2\t max\t vsmean_nat_run1\t vsmean_nat_run2\t vsmean_stan_run1\t vsmean_stan_run2"

# Define a function to process a single subject
process_subject() {
    sub=$1
    for task in "${tasks[@]}"; do
        cd "$datadir/sub-${sub}/func" || return

        # Process _stan data
        for run in 1 2; do
            for i in sub-${sub}_task-${task}_run-${run}_space-MNI152NLin6Asym_desc-preproc_bold.nii.gz; do
                fslmaths "$i" -Tmean tmp_mean
                fslmaths "$i" -Tstd tmp_std
                fslmaths tmp_mean -div tmp_std tmp_tsnr
                fslmaths tmp_tsnr -thr 2 thr_tmp_tsnr
                max=$(fslstats thr_tmp_tsnr -R | awk '{ print $2 }')
                mean_stan=$(fslstats thr_tmp_tsnr -k /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/func/sub-${sub}_task-${task}_run-${run}_space-MNI152NLin6Asym_desc-brain_mask.nii.gz -M)
                vsmean_stan=$(fslstats thr_tmp_tsnr -k /ZPOOL/data/projects/rf1-sra-trust/masks/VS-Imanova_2mm_re.nii -M)
                echo -e "$i\t $mean_stan\t $vsmean_stan\t $max"
            done
        done

        # Process _nat data
        for run in 1 2; do
            for echo in 1 2 3 4; do
                for i in sub-${sub}_task-${task}_run-${run}_echo-${echo}_desc-preproc_bold.nii.gz; do 
                    fslmaths "$i" -Tmean tmp_mean
                    fslmaths "$i" -Tstd tmp_std
                    fslmaths tmp_mean -div tmp_std tmp_tsnr
                    fslmaths tmp_tsnr -thr 2 thr_tmp_tsnr
                    max=$(fslstats thr_tmp_tsnr -R | awk '{ print $2 }')
                    mean_nat=$(fslstats thr_tmp_tsnr -k /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/func/sub-${sub}_task-${task}_run-${run}_desc-brain_mask.nii.gz -M)
                    vsmean_nat=$(fslstats thr_tmp_tsnr -k /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/sub-${sub}_task-${task}_run-${run}_space-native_roi-vs_thr_mask.nii.gz -M)
                    echo -e "$i\t $mean_nat\t $vsmean_nat\t $max"
                done
            done
        done
    done
}

# Read the subject list and process subjects one at a time
while IFS= read -r sub; do
    process_subject "$sub"
done < /ZPOOL/data/projects/rf1-sra-trust/code/sublist_h5.txt
