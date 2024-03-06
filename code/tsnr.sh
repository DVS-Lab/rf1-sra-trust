#!/bin/bash

# Set the number of cores to use
NCORES=20

# ensure paths are correct irrespective from where user runs the script
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
#maindir="$(dirname "$scriptdir")"

# Define the data directory
datadir=/ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep
task=trust

echo -e "sub\tmean\tmax\tmeanVS\t" 

# Define a function to process a single subject
process_subject() {
    sub=$1
    cd "$datadir/sub-${sub}/func" || return
    for i in sub-${sub}_task-${task}*_echo-*_bold.nii.gz; do
        fslmaths "$i" -Tmean tmp_mean
        fslmaths "$i" -Tstd tmp_std
        fslmaths tmp_mean -div tmp_std tmp_tsnr
        fslmaths tmp_tsnr -thr 2 thr_tmp_tsnr
        max=$(fslstats thr_tmp_tsnr -R | awk '{ print $2 }')
        mean=$(fslstats thr_tmp_tsnr -M)
        vsmean=$(fslstats thr_tmp_tsnr -k /ZPOOL/data/projects/rf1-sra-trust/masks/seed-VS_preproc.nii.gz -M)
        echo -e "$i\t $mean\t $max\t $vsmean"
    done
}

# Read the subject list and process subjects in parallel
while IFS= read -r sub; do
	NCORES=20
    process_subject "$sub" &
    if [[ $(jobs -r -p | wc -l) -ge $NCORES ]]; then
        wait -n
    fi
done < /ZPOOL/data/projects/rf1-sra-trust/code/sublist_all.txt

# Wait for all remaining jobs to finish
wait
