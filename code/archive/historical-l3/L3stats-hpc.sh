#!/bin/bash
#PBS -l walltime=03:00:00
#PBS -N L3stats-aging
#PBS -q large
#PBS -m ae
#PBS -M cooper.sharp@temple.edu
#PBS -l nodes=2:ppn=16

# load modules and go to workdir
source $FSLDIR/etc/fslconf/fsl.sh
cd $PBS_O_WORKDIR

maindir=/gpfs/scratch/tug87422/smithlab-shared/rf1-sra-trust
logdir=/$maindir/logs
mkdir -p $logdir

rm -f L3stats-aging.o*
rm -f L3stats-aging.e*

rm -f $logdir/cmd_feat_${PBS_JOBID}.txt
touch $logdir/cmd_feat_${PBS_JOBID}.txt

# study-specific inputs and general output folder
task=trust
N=112
model="sogs"
seed="VS"
copenum_thresh_randomise=10 # actual contrasts start with cope10 (rec > def). no need to do randomise main effects (e.g., rec > nothing/fixation/baseline)
REPLACEME="ppi_seed-VS" # this defines the parts of the path that differ across analyses
MAINOUTPUT=${maindir}/derivatives/fsl/L3${REPLACEME}/L3_model-${model}_task-${task}_n${N}_flame1-zstat
mkdir -p $MAINOUTPUT

#### --- Two groups ------------------------------
# set outputs and check for existing

for copeinfo in "4 C_def" "5 C_rec" "6 F_def" "7 F_rec" "8 S_def" "9 S_rec" "10 rec-def" "12 rec-def_F-S" "16 rec-def_SocClose" "17 def_SocColse" "18 rec-def_SocClose" "19 phys"; do

	set -- $copeinfo
	copenum=$1
	copename=$2
	REPLACEME="ppi_seed-VS"

	# skip non-existent contrast for activation analysis
	if [ "${REPLACEME}" == "act" ] && [ "${copeinfo}" == "33 phys" ]; then
			echo "skipping phys for activation since it does not exist..."
			continue
	fi

	cnum_pad=`zeropad ${copenum} 2`
	OUTPUT=${MAINOUTPUT}/L3_task-${task}_type-${REPLACEME}_cnum-${cnum_pad}_cname-${copename}_onegroup


	echo "re-doing: ${OUTPUT}" >> re-runL3.log
	rm -rf ${OUTPUT}.gfeat

	# create template and run FEAT analyses, removed the N because of sogs typo
	ITEMPLATE=${maindir}/templates/L3_template_n${N}_${task}_model-${model}_onegroup.fsf
	OTEMPLATE=${MAINOUTPUT}/L3_task-${task}_type-${REPLACEME}_copenum-${copenum}.fsf
	sed -e 's@OUTPUT@'$OUTPUT'@g' \
	-e 's@COPENUM@'$copenum'@g' \
	-e 's@REPLACEME@'$REPLACEME'@g' \
	-e 's@BASEDIR@'$maindir'@g' \
	<$ITEMPLATE> $OTEMPLATE
	echo feat $OTEMPLATE >> $logdir/cmd_feat_${PBS_JOBID}.txt

	# delete unused files
	rm -rf ${OUTPUT}.gfeat/cope${cope}.feat/stats/res4d.nii.gz
	rm -rf ${OUTPUT}.gfeat/cope${cope}.feat/stats/corrections.nii.gz
	rm -rf ${OUTPUT}.gfeat/cope${cope}.feat/stats/threshac1.nii.gz
	#rm -rf ${OUTPUT}.gfeat/cope${cope}.feat/filtered_func_data.nii.gz
	rm -rf ${OUTPUT}.gfeat/cope${cope}.feat/var_filtered_func_data.nii.gz

done

torque-launch -p $logdir/chk_feat_${PBS_JOBID}.txt $logdir/cmd_feat_${PBS_JOBID}.txt

