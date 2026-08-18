#!/bin/bash

# ensure paths are correct
maindir=~/work/rf1-sra-trust #this should be the only line that has to change if the rest of the script is set up correctly
scriptdir=$maindir/code


mapfile -t myArray < sublist-rf1.txt


# grab the first 2 elements
ntasks=5
counter=0
for task in trust; do
	for type in "ppi"; do #"VS_thr5" "dmn"; do # 0 "VS_thr5" "dmn"; do # putting 0 first will indicate "activation"
		#for run in 1 2; do
		
		while [ $counter -lt ${#myArray[@]} ]; do
			subjects=${myArray[@]:$counter:$ntasks}
			echo $subjects
			let counter=$counter+$ntasks
			qsub -v subjects="${subjects[@]}" L2stats-hpc.sh
		done

			#bash $sub $type &
	  		sleep 1s
			done	  	
	  	done
	#done
