#!/bin/bash

# ensure paths are correct irrespective from where user runs the script
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
maindir="$(dirname "$scriptdir")"

# the "type" variable below is setting a path inside the main script
for type in act ppi_seed-VS; do
	for subrun in "10418 2"; do #"10572 2" "10581 2" "10585 2" "10589 2" "10596 2" "10603 2" "10606 2" "10644 2" "10656 2" "10663" "10673 2" "10677 2"
			set -- $subrun
			sub=$1
			nruns=$2

			# Manages the number of jobs and cores
	  	SCRIPTNAME=${maindir}/code/L2stats.sh
	  	NCORES=22
	  	while [ $(ps -ef | grep -v grep | grep $SCRIPTNAME | wc -l) -ge $NCORES ]; do
	    		sleep 1s
	  	done
	  	bash $SCRIPTNAME $sub $nruns $type &
	  	sleep 1s
	done
done
