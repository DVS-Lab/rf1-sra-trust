#!/bin/bash

# ensure paths are correct
maindir=/gpfs/scratch/tug87422/smithlab-shared/rf1-sra-data #this should be the only line that has to change if the rest of the script is set up correctly
scriptdir=/gpfs/scratch/tug87422/smithlab-shared/rf1-sra-trust/code


mapfile -t myArray < sublist_N142.txt


# grab the first 10 elements
ntasks=5
counter=0
for task in trust; do
	for ppi in "VS"; do #"VS_thr5" "dmn"; do # 0 "VS_thr5" "dmn"; do # putting 0 first will indicate "activation"
		for run in 1 2; do
		
		while [ $counter -lt ${#myArray[@]} ]; do
			subjects=${myArray[@]:$counter:$ntasks}
			echo $subjects
			let counter=$counter+$ntasks
			qsub -v subjects="${subjects[@]}" L1stats-hpc.sh
		done

			bash $SCRIPTNAME $sub $run $ppi $task &
	  		sleep 1s
			done	  	
	  	done
	#done
