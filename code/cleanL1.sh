#!/usr/bin/env bash
# ensure paths are correct irrespective from where user runs the script
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
maindir="$(dirname "$scriptdir")"
TASK=trust
ppi=0
sm=5

# need to change this to a more targetted list of subjects
# also should only run this if the inputs exist. add if statements.
for sub in `cat $scriptdir/sublist_DD128.txt`; do
	echo $sub
	#sub=${sub:(-5)}
	echo $sub 
	for run in 1 2; do

		# set inputs and general outputs (should not need to chage across studies in Smith Lab)
		MAINOUTPUT=${maindir}/derivatives/fsl/sub-${sub}

		# if network (ecn or dmn), do nppi; otherwise, do activation or seed-based ppi
		if [ "$ppi" == "ecn" -o  "$ppi" == "dmn" ]; then
			OUTPUT=${MAINOUTPUT}/L1_task-${TASK}_model-1_type-melodic-nppi-${ppi}_run-${run}_sm-${sm}
		else # otherwise, do activation and seed-based ppi
			# set output based in whether it is activation or ppi
			if [ "$ppi" == "0" ]; then
				TYPE=act
				OUTPUT=${MAINOUTPUT}/L1_task-${TASK}_model-1_type-${TYPE}_run-${run}_sm-${sm}
			else
				TYPE=ppi
				OUTPUT=${MAINOUTPUT}/L1_task-${TASK}_model-1_type-${TYPE}_seed-${ppi}_run-${run}_sm-${sm}
			fi
		fi

		echo "fix registration and deleting unused files: $OUTPUT"
		
		# fix registration as per NeuroStars post:
		# https://neurostars.org/t/performing-full-glm-analysis-with-fsl-on-the-bold-images-preprocessed-by-fmriprep-without-re-registering-the-data-to-the-mni-space/784/3
		mkdir -p ${OUTPUT}.feat/reg
		cp -r $FSLDIR/etc/flirtsch/ident.mat ${OUTPUT}.feat/reg/example_func2standard.mat
		cp -r $FSLDIR/etc/flirtsch/ident.mat ${OUTPUT}.feat/reg/standard2example_func.mat
		cp -r ${OUTPUT}.feat/mean_func.nii.gz ${OUTPUT}.feat/reg/standard.nii.gz

		# delete unused files
		rm -rf ${OUTPUT}.feat/stats/res4d.nii.gz
		rm -rf ${OUTPUT}.feat/stats/corrections.nii.gz
		rm -rf ${OUTPUT}.feat/stats/threshac1.nii.gz
		rm -rf ${OUTPUT}.feat/filtered_func_data.nii.gz

	done
done
