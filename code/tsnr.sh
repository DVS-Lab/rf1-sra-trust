#!/bin/bash

# Set the number of cores to use
NCORES=20

# ensure paths are correct irrespective from where user runs the script
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
#maindir="$(dirname "$scriptdir")"

# Define the data directory
datadir=/ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep
tasks=("trust" "ugr" "sharedreward")


#echo -e "sub\tmean\tmax\tmeanVS_run1\tmeanVS_run2\t"
echo -e "sub\t mean_stan_run1\t mean_stan_run2\t mean_nat_run1\t mean_nat_run2\t max\t vsmean_run1\t vsmean_run2" 

# Define a function to process a single subject
process_subject() {
    sub=$1
    for task in "${tasks[@]}"; do
    cd "$datadir/sub-${sub}/func" || return


## Native mask: sub-10661_task-doors_run-1_desc-brain_mask.nii.gz
## Standard mask: sub-10661_task-doors_run-1_space-MNI152NLin6Asym_desc-brain_mask.nii.gz
## Should have a standard and native fslmaths for whole brain
    
    # Apply transformation using antsApplyTransforms for run-1
    antsApplyTransforms \
    -i /ZPOOL/data/projects/rf1-sra-trust/masks/VS-Imanova_2mm.nii \
    -r /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/func/sub-${sub}_task-${task}_run-1_part-mag_desc-coreg_boldref.nii.gz \
    -t /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/anat/sub-${sub}_from-MNI152NLin6Asym_to-T1w_mode-image_xfm.h5 \
    -t [/ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/func/sub-${sub}_task-${task}_run-1_from-boldref_to-T1w_mode-image_desc-coreg_xfm.txt, 1] \
    -n Linear \
    -o /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/sub-${sub}_task-${task}_run-1_space-native_roi-vs_mask.nii.gz
    
    # Apply transformation using antsApplyTransforms for run-2
    antsApplyTransforms \
    -i /ZPOOL/data/projects/rf1-sra-trust/masks/VS-Imanova_2mm.nii \
    -r /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/func/sub-${sub}_task-${task}_run-2_part-mag_desc-coreg_boldref.nii.gz \
    -t /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/anat/sub-${sub}_from-MNI152NLin6Asym_to-T1w_mode-image_xfm.h5 \
    -t [/ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/func/sub-${sub}_task-${task}_run-2_from-boldref_to-T1w_mode-image_desc-coreg_xfm.txt, 1] \
    -n Linear \
    -o /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/sub-${sub}_task-${task}_run-2_space-native_roi-vs_mask.nii.gz
    
#        # Apply transformation using antsApplyTransforms for run-2
#    antsApplyTransforms \
#    -i /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/func/sub-${sub}_task-${task}_run-1_desc-brain_mask.nii.gz \
#    -r /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/func/sub-${sub}_task-${task}_run-1_part-mag_desc-coreg_boldref.nii.gz \
#    -t /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/anat/sub-${sub}_from-MNI152NLin6Asym_to-T1w_mode-image_xfm.h5 \
#    -t [/ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/func/sub-${sub}_task-${task}_run-1_from-boldref_to-T1w_mode-image_desc-coreg_xfm.txt, 1] \
#    -n Linear \
#    -o /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/sub-${sub}_task-${task}_run-1_space-native_roi-wholebrain_mask.nii.gz
#    
#    antsApplyTransforms \
#	 -i /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/func/sub-${sub}_task-${task}_run-2_desc-brain_mask.nii.gz \
#    -r /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/func/sub-${sub}_task-${task}_run-2_part-mag_desc-coreg_boldref.nii.gz \
#    -t /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/anat/sub-${sub}_from-MNI152NLin6Asym_to-T1w_mode-image_xfm.h5 \
#    -t [/ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/func/sub-${sub}_task-${task}_run-2_from-boldref_to-T1w_mode-image_desc-coreg_xfm.txt, 1] \
#    -n Linear \
#    -o /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/sub-${sub}_task-${task}_run-2_space-native_roi-wholebrain_mask.nii.gz
        
    
    # Threshold and binarize the generated masks for both runs
    fslmaths /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/sub-${sub}_task-${task}_run-1_space-native_roi-vs_mask.nii.gz -thr 0.5 -bin /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/sub-${sub}_task-${task}_run-1_space-native_roi-vs_thr_mask.nii.gz
    fslmaths /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/sub-${sub}_task-${task}_run-2_space-native_roi-vs_mask.nii.gz -thr 0.5 -bin /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/sub-${sub}_task-${task}_run-2_space-native_roi-vs_thr_mask.nii.gz
	 fslmaths /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/sub-${sub}_task-${task}_run-1_space-native_roi-wholebrain_mask.nii.gz -thr 0.5 -bin /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/sub-${sub}_task-${task}_run-1_space-native_roi-wholebrain_thr_mask.nii.gz    
    fslmaths /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/sub-${sub}_task-${task}_run-2_space-native_roi-wholebrain_mask.nii.gz -thr 0.5 -bin /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/sub-${sub}_task-${task}_run-2_space-native_roi-wholebrain_thr_mask.nii.gz    
	 #fslmaths /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/func/sub-${sub}_task-${task}_run-1_space-MNI152NLin6Asym_desc-brain_mask.nii.gz -thr 0.5 -bin /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/sub-${sub}_task-${task}_run-1_space-MNI152NLin6Asym_desc-brain_thr_mask.nii.gz    
    #fslmaths /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/func/sub-${sub}_task-${task}_run-2_space-MNI152NLin6Asym_desc-brain_mask.nii.gz -thr 0.5 -bin /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/sub-${sub}_task-${task}_run-2_space-MNI152NLin6Asym_desc-brain_thr_mask.nii.gz    
    
    
    for i in sub-${sub}_task-${task}_run-*_echo-*_desc-preproc_bold.nii.gz; do
        fslmaths "$i" -Tmean tmp_mean
        fslmaths "$i" -Tstd tmp_std
        fslmaths tmp_mean -div tmp_std tmp_tsnr
        fslmaths tmp_tsnr -thr 2 thr_tmp_tsnr
        max=$(fslstats thr_tmp_tsnr -R | awk '{ print $2 }')
        mean_stan_run1=$(fslstats thr_tmp_tsnr -k /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/func/sub-${sub}_task-${task}_run-1_space-MNI152NLin6Asym_desc-brain_mask.nii.gz-M)
        mean_stan_run2=$(fslstats thr_tmp_tsnr -k /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/func/sub-${sub}_task-${task}_run-2_space-MNI152NLin6Asym_desc-brain_mask.nii.gz-M)
        mean_nat_run1=$(fslstats thr_tmp_tsnr -k /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/sub-${sub}_task-${task}_run-1_space-native_roi-wholebrain_thr_mask.nii.gz -M)
        mean_nat_run2=$(fslstats thr_tmp_tsnr -k /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/sub-${sub}_task-${task}_run-2_space-native_roi-wholebrain_thr_mask.nii.gz -M)
        vsmean_run1=$(fslstats thr_tmp_tsnr -k /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/sub-${sub}_task-${task}_run-1_space-native_roi-vs_thr_mask.nii.gz -M)
        vsmean_run2=$(fslstats thr_tmp_tsnr -k /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/sub-${sub}_task-${task}_run-2_space-native_roi-vs_thr_mask.nii.gz -M)
        echo -e "$i\t $mean_stan_run1\t $mean_stan_run2\t $mean_nat_run1\t $mean_nat_run2\t $max\t $vsmean_run1\t $vsmean_run2"
    done
   done
}

# Read the subject list and process subjects in parallel
while IFS= read -r sub; do
    NCORES=20
    process_subject "$sub" &
    if [[ $(jobs -r -p | wc -l) -ge $NCORES ]]; then
        wait -n
    fi
done < /ZPOOL/data/projects/rf1-sra-trust/code/sublist_h5.txt

# Wait for all remaining jobs to finish
wait

