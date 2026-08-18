#!/usr/bin/env bash

# Define the absolute path to your project directory
maindir="/ZPOOL/data/projects/rf1-sra-linux2"
# Set the BIDS and Output directories
bidsdir="${maindir}/bids"
baseout="${maindir}/derivatives/fsl/EVfiles"

# Loop through all subject directories in the BIDS folder
for subdir in ${bidsdir}/sub-*; do
    
    # Extract the subject ID from the folder name
    sub=$(basename $subdir | sed 's/sub-//')
    
    echo "Processing sub-${sub}..."

    for run in 1 2; do
        # Define the exact path to the input .tsv file
        input="${subdir}/ses-01/func/sub-${sub}_task-trust_run-${run}_events.tsv"
        # Define the output directory for this specific subject
        output="${baseout}/sub-${sub}/trust"
        
        # Create the output directory if it doesn't exist
        mkdir -p "$output"
        
        if [ -e "$input" ]; then
            # Run the converter script
            bash /ZPOOL/data/tools/BIDSto3col.sh "$input" "${output}/run-${run}"
        else
            # Error handling if the file is missing
            echo "PATH ERROR: cannot locate ${input}."
            continue
        fi
    done
done
