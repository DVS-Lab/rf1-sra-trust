#!/bin/bash
#PBS -l walltime=24:00:00
#PBS -N L3stats-ugr
#PBS -q normal
#PBS -m ae
#PBS -M derrick.dwamena@temple.edu
#PBS -l nodes=2:ppn=28

#source $FSLDIR/etc/fslconf/fsl.sh
#cd $PBS_O_WORKDIR
# Note that you never need to input 
# Vars
task=${task:-"ugr"}
model=${model:-"3"}
modeltype="flame1"
N=128
covariate=${covariate:-"dACC"}  # or whatever your default should be
REPLACEME=${REPLACEME:-"act"}  # shouldnt need to be touched; just defaults to "act" if there is no input after bash run_L3 command

# Base paths
maindir=/gpfs/scratch/tug87422/smithlab-shared/rf1-sra-trust
templatedir=${maindir}/templates
logdir=${maindir}/logs
mkdir -p $logdir

# Add ROI suffix only for ppi mode
roi_suffix=""
if [[ "$REPLACEME" == "ppi" ]]; then
  roi_suffix="_seed-${ROI}"
fi

# Output directory
MAINOUTPUT=${maindir}/derivatives/fsl/L3-${REPLACEME}-${ROI}-3/L3_model-${model}_task-${task}_type-${REPLACEME}-n${N}-cov-${covariate}-${modeltype}
#MAINOUTPUT=${maindir}/derivatives/fsl/L3_model-${model}_task-${task}_type-${REPLACEME}-n${N}-cov-${covariate}-${modeltype}
mkdir -p $MAINOUTPUT

# Command file
cmdfile=$logdir/cmd_feat_${PBS_JOBID}.txt
rm -f $cmdfile
touch $cmdfile

# Loop over contrasts
for copeinfo in "11 offer-unfairness_pmod"; do
    # "11 offer-unfairness_pmod"
    # "1 nonsocial_level1" "2 nonsocial_level2" "3 nonsocial_level3" "4 nonsocial_level4" \
    # "5 social_level1" "6 social_level2" "7 social_level3" "8 social_level4" \
    # "9 endowment-high>low_c" "10 social-nonsocial_c" \
    # "11 offer-unfairness_pmod" "12 social-nonsocial_pmod" \
    # "13 nonsocial_pmod" "14 social_pmod" "15 endowment_high-low_pmod" \
    # "16 nonsocial_high-low_pmod" "17 social_high-low_pmod"; do

    # "1 nonsocial_high_c" "2 nonsocial_high_pmod" "3 nonsocial_low_c" "4 nonsocial_low_pmod" \
    # "5 social_high_c" "6 social_high_pmod" "7 social_low_c" "8 social_low_pmod" \
    # "9 endowment_high-low_c" "10 social-nonsocial_c" \
    # "11 offer-unfairness_pmod" "12 social-nonsocial_pmod" \
    # "13 nonsocial_pmod" "14 social_pmod" "15 endowment_high-low_pmod" \
    # "16 nonsocial_high-low_pmod" "17 social_high-low_pmod" "18 phys"; do

    set -- $copeinfo
    copenum=$1
    copename=$2
    cnum_pad=$(printf "%02d" $copenum)

    OUTPUT=${MAINOUTPUT}/L3_task-${task}_type-${REPLACEME}${roi_suffix}_cnum-${cnum_pad}_cname-${copename}_onegroup
    mkdir -p $(dirname $OUTPUT)

    ITEMPLATE=${templatedir}/L3_task-${task}_model-${model}_type-${REPLACEME}_group-${covariate}_n${N}_${modeltype}.fsf
    OTEMPLATE=${MAINOUTPUT}/L3_task-${task}_model-${model}_type-${REPLACEME}${roi_suffix}_cope-${copenum}_cname-${copename}_${covariate}_n${N}_${modeltype}.fsf

    echo "[$(date)] Re-doing: ${OUTPUT}" >> $maindir/L3_log/re-runL3_type-${REPLACEME}_group-${covariate}_${PBS_JOBID}.log
    rm -rf ${OUTPUT}.gfeat

    sed -e "s@OUTPUT@${OUTPUT}@g" \
        -e "s@COPENUM@${copenum}@g" \
        -e "s@REPLACEME@${REPLACEME}@g" \
        -e "s@BASEDIR@${maindir}@g" \
        -e "s@ROI@${ROI}@g" \
        < $ITEMPLATE > $OTEMPLATE

    echo "feat $OTEMPLATE" >> $cmdfile
    echo "rm -rf ${OUTPUT}.gfeat/cope${copenum}.feat/stats/res4d.nii.gz" >> $cmdfile
    echo "rm -rf ${OUTPUT}.gfeat/cope${copenum}.feat/stats/corrections.nii.gz" >> $cmdfile
    echo "rm -rf ${OUTPUT}.gfeat/cope${copenum}.feat/stats/threshac1.nii.gz" >> $cmdfile
    echo "rm -rf ${OUTPUT}.gfeat/cope${copenum}.feat/var_filtered_func_data.nii.gz" >> $cmdfile
done

# Submit all FEATs
torque-launch -p $logdir/chk_feat_${PBS_JOBID}.txt $cmdfile

