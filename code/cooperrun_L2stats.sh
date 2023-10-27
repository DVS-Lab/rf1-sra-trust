#!/bin/bash

# ensure paths are correct irrespective from where user runs the script
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
maindir="$(dirname "$scriptdir")"

# the "type" variable below is setting a path inside the main script
for type in act ppi_seed-VS; do
	for subrun in "10478 2" "10529 2" "10541 2"; do
			set -- $subrun
			sub=$1
			nruns=$2

			# Manages the number of jobs and cores
	  	SCRIPTNAME=${maindir}/code/cooperL2stats.sh
	  	NCORES=22
	  	while [ $(ps -ef | grep -v grep | grep $SCRIPTNAME | wc -l) -ge $NCORES ]; do
	    		sleep 1s
	  	done
	  	bash $SCRIPTNAME $sub $nruns $type &
	  	sleep 1s

	done
done
