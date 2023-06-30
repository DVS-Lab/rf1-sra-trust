#!/bin/bash

# ensure paths are correct irrespective from where user runs the script
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
basedir="$(dirname "$scriptdir")"

for ppi in 0 "VS"; do # putting 0 first will indicate "activation"; putting the name of a mask will indicate ppi
	for subrun in "10418 2"; do #"10369 2" "10402 2" "10418 2" "10462 2" "10478 2" "10529 2" "10541 2" "10572 2" "10581 2" "10584 2" "10585 2" "10589 2" "10596 2" "10603 2" "10606 2" "10608 2" "10644 2" "10617 2" "10656 2" "10657 2" "10663 2" "10673 2" "10677 2"; do

	  set -- $subrun
	  sub=$1
	  nruns=$2

	  for run in `seq $nruns`; do
	  	# Manages the number of jobs and cores
	  	SCRIPTNAME=${basedir}/code/L1stats.sh
	  	NCORES=20
	  	while [ $(ps -ef | grep -v grep | grep $SCRIPTNAME | wc -l) -ge $NCORES ]; do
	    		sleep 1s
	  	done
	  	bash $SCRIPTNAME $sub $run $ppi &
	  	sleep 1s
	  done

	done
done
