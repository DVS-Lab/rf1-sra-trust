#!/usr/bin/env bash

# ensure paths are correct irrespective from where user runs the script
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
maindir="$(dirname "$scriptdir")"

# DMN-TPJ
# ECN-Insula

# ROI name and other path information
for TYPE in act; do
	for ROI in seed-dlPFC; do
		MASK=${maindir}/masks/${ROI}.nii.gz
		TASK=trust
		group=twogroup
		N=87
		outputdir=${maindir}/derivatives/imaging_plots/
		mkdir -p $outputdir

		for model in age; do 
			#for copeinfo in "4 C_def" "5 C_rec" "6 F_def" "7 F_rec" "8 S_def" "9 S_rec" "10 rec-def" "11 face" "12 rec-def_F-S" "13 F-S" "14 F-C" "15 S-C" "16 rec_SocClose" "17 def_SocClose" "18 rec-def_SocClose"; do
			#for copeinfo in "10 rec-def" "12 rec-def_F-S" "16 rec_SocClose" "17 def_SocClose" "18 rec-def_SocClose"; do
			for copeinfo in "16 rec_SocClose"; do	
				# split copeinfo variable				
				set -- $copeinfo
				copenum=$1
				copename=$2
				MAINOUTPUT=${maindir}/derivatives/fsl/L3act/L3_model-${model}_task-trust_n${N}_flame1
				DATA=`ls -1 ${MAINOUTPUT}/L3_task-${TASK}_${TYPE}_cnum-${copenum}_cname-${copename}_${group}.gfeat/cope1.feat/filtered_func_data.nii.gz`
				fslmeants -i $DATA -o ${outputdir}/${ROI}_model-${model}_type-${TYPE}_cope-${copenum}_cname-${copename}.txt -m ${MASK}
			done
		done
	done
done