import os
import glob
import pandas as pd
import shutil
import re

# Define the base directory and the output directory
base_dir = '/ZPOOL/data/projects/rf1-sra/stimuli/Scan-Investment_Game/logs/'
output_dir = '/ZPOOL/data/projects/rf1-sra-trust/derivatives/behavioral/ratings/'

def clear_output_directory(output_dir):
    """
    Clear the output directory by removing all existing files.
    """
    if os.path.exists(output_dir):
        shutil.rmtree(output_dir)
    os.makedirs(output_dir)
    print(f"Cleared and recreated output directory: {output_dir}")

def extract_sub_value(file_path):
    """
    Extract the participant ID (sub value) from the filename.
    """
    # Extract participant ID using a regular expression
    filename = os.path.basename(file_path)
    match = re.match(r'sub-(\d+)_Trust-Ratings\.csv', filename)
    if match:
        return match.group(1)
    return "Unknown"

def transform_data(data, sub_value):
    """
    Transform the data to the required format:
    - partner: 1 -> "computer", 2 -> "stranger", 3 -> "friend"
    - trait: 0 -> "approachable", 1 -> "likeable", 2 -> "trustworthy"
    """
    # Map for partner and trait
    partner_map = {1: "computer", 2: "stranger", 3: "friend"}
    trait_map = {0: "approachable", 1: "likeable", 2: "trustworthy"}

    # Initialize a dictionary to collect transformed data
    transformed_dict = {'sub': sub_value}
    
    for _, row in data.iterrows():
        column_name = f"{partner_map.get(row['Partner'], 'Unknown')}_{trait_map.get(row['Trait'], 'Unknown')}"
        transformed_dict[column_name] = row["Rating"]
    
    return pd.DataFrame([transformed_dict])

def process_directories(base_dir, output_dir):
    """
    Traverse directories under base_dir and process sub-*****_Trust-Ratings.csv files.
    Save the transformed files to output_dir.
    """
    # Clear the output directory before processing new files
    clear_output_directory(output_dir)
    
    # Use glob to find all CSV files under the base_dir path
    file_pattern = os.path.join(base_dir, '*/sub-*_Trust-Ratings.csv')
    csv_files = glob.glob(file_pattern)
    
    all_transformed_data = []

    for file_path in csv_files:
        # Extract participant ID from filename
        sub_value = extract_sub_value(file_path)
        
        # Read the CSV file
        data = pd.read_csv(file_path)
        
        # Transform the data
        transformed_data = transform_data(data, sub_value)
        
        # Append transformed data to list
        all_transformed_data.append(transformed_data)

    # Combine all transformed data
    combined_data = pd.concat(all_transformed_data)
    
    # Define the output file path
    output_file_path = os.path.join(output_dir, 'aggregated_transformed_data.csv')
    
    # Save the aggregated data to a new CSV file
    combined_data.to_csv(output_file_path, index=False)
    print(f"Aggregated and transformed data saved to {output_file_path}")

if __name__ == "__main__":
    process_directories(base_dir, output_dir)
