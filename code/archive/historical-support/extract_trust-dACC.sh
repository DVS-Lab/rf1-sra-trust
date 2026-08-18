#!/bin/bash

# Set script directory and base directory (borrowed style from L1stats.sh)
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
basedir="$(dirname "$scriptdir")"

# Define input variables
sublist="${scriptdir}/sublist_N142.txt"
task="trust"
model="1"
sm="5"
mask="/gpfs/scratch/tug87422/smithlab-shared/rf1-norms/masks/thr_seed-dACC.nii.gz"

# Output directory for the meants text files
outputdir="${basedir}/derivatives/dACC_trust_meants"
mkdir -p $outputdir

# Loop through each subject
for sub in `cat ${basedir}/code/sublist_N142.txt`; do
#for sub in 10402; do 
  # Define the path to the filtered functional data
 # /gpfs/scratch/tug87422/smithlab-shared/rf1-sra-trust/derivatives/fsl/sub-10402/L2_task-trust_model-1_type-act_sm-5.gfeat/cope10.feat/stats

  DATA="/gpfs/scratch/tug87422/smithlab-shared/rf1-sra-trust/derivatives/fsl/sub-${sub}/L2_task-${task}_model-${model}_type-act_sm-${sm}.gfeat/cope10.feat/stats/cope1.nii.gz"
  DATArun1="/gpfs/scratch/tug87422/smithlab-shared/rf1-sra-trust/derivatives/fsl/sub-${sub}/L1_task-${task}_model-${model}_type-act_run-1_sm-${sm}.feat/stats/cope10.nii.gz"
  DATArun2="/gpfs/scratch/tug87422/smithlab-shared/rf1-sra-trust/derivatives/fsl/sub-${sub}/L1_task-${task}_model-${model}_type-act_run-2_sm-${sm}.feat/stats/cope10.nii.gz"
  # Definec the output file
  
  # Check if the data file exists
  if [ -f "$DATA" ]; then   
     echo "Extracting L2 dACC signal for subject: ${sub}"
    OUTPUT="${outputdir}/sub-${sub}_L2_dACC_meants.txt"
    fslmeants -i $DATA -o $OUTPUT -m $mask
  else
    echo "sub${sub} ${DATA} doesn't exist"
  fi
  	
   if [ -f "$DATArun1" ]; then
   	 echo "Extracting run1 dACC signal for subject: ${sub}"
   	 OUTPUT="${outputdir}/sub-${sub}_run-1_dACC_meants.txt"
   	 fslmeants -i $DATArun1 -o $OUTPUT -m $mask
   else 
   	 echo "WARNING: Run-1 ${DATArun1} not found for subject ${sub}. Skipping."
   fi
 	if [ -f "$DATArun2" ]; then
   	 echo "Extracting run2 dACC signal for subject: ${sub}"
   	 OUTPUT="${outputdir}/sub-${sub}_run-2_dACC_meants.txt"
   	 fslmeants -i $DATArun2 -o $OUTPUT -m $mask
   else 
   	 echo "WARNING: Run-2 ${DATArun2} not found for subject ${sub}. Skipping."
   fi

done

echo "Extraction complete. All output files saved to: $outputdir"
