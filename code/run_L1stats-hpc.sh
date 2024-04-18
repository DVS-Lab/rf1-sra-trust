!#/bin/bash
#
# Ensure paths are correct irrespective from where user runs the script
#scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
#basedir="$(dirname "$scriptdir")"
#nruns=2
#
#for task in socialdoors; do
#for task in trust; do
#	for ppi in 0 "VS"; do #"VS_thr5" "dmn"; do # 0 "VS_thr5" "dmn"; do # putting 0 first will indicate "activation"
#		#for sub in 10668; do #-- use this line for testing with one subject 
#		for sub in `cat ${basedir}/code/sublist_hpc.txt`; do
#	  		for run in 1 2; do
#
#		  		# Manages the number of jobs and cores
#		  		SCRIPTNAME=${basedir}/code/L1stats-hpc.sh
#	  			NCORES=20
#	  			while [ $(ps -ef | grep -v grep | grep $SCRIPTNAME | wc -l) -ge $NCORES ]; do
#	    			sleep 5s
#	  			done
#
#	  		bash $SCRIPTNAME $sub $run $ppi $task &
#	  		sleep 1s
#
#			done	  	
#	  	done
#	done
#done
#
#!/bin/bash

# ensure paths are correct
maindir=~/work/rf1-sra-data #this should be the only line that has to change if the rest of the script is set up correctly
scriptdir=$trustdir/code


mapfile -t myArray < ${scriptdir}/sublist_hpc.txt


# grab the first 10 elements
ntasks=2
counter=0
for task in trust; do
	for ppi in 0 "VS"; do #"VS_thr5" "dmn"; do # 0 "VS_thr5" "dmn"; do # putting 0 first will indicate "activation"
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
	done