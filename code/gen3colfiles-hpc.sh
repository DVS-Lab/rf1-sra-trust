#!/usr/bin/env bash

# this script will convert your BIDS *events.tsv files into the 3-col format for FSL
# it relies on Tom Nichols' converter, which we store locally under /data/tools
# https://github.com/bids-standard/bidsutils


scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
maindir="$(dirname "$scriptdir")"
baseout=${maindir}/derivatives/fsl/EVfiles
if [ ! -d ${baseout} ]; then
  mkdir -p $baseout
fi

sub=$1
task="trust"

for run in 1 2; do
  input=/gpfs/scratch/tug87422/smithlab-shared/rf1-sra-data/bids/sub-${sub}/func/sub-${sub}_task-${task}_run-${run}_events.tsv
  output=${baseout}/sub-${sub}/${task}
  mkdir -p $output
  if [ -e $input ]; then
    bash /home/tun31934/work/tools/BIDSto3col.sh $input ${output}/run-${run}
  else
    echo "PATH ERROR: cannot locate ${input}."
  fi
done
