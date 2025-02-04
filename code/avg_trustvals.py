import os
import pandas as pd

# Directories and file paths
maindir = '/ZPOOL/data/projects/rf1-sra-data'
rawdata = os.path.join(maindir, 'bids')
basedir = '/ZPOOL/data/projects/rf1-sra-trust'
outdir = os.path.join(basedir, 'derivatives', 'behavioral')

if not os.path.exists(outdir):
    os.makedirs(outdir)

sublist = [
    10402, 10418, 10462, 10478, 10486, 10529, 10541, 10559, 10572, 10581, 10584, 10585, 10589,
    10590, 10596, 10603, 10606, 10608, 10617, 10636, 10638, 10640, 10641, 10642, 10644, 10647,
    10649, 10652, 10656, 10657, 10661, 10663, 10668, 10673, 10674, 10677, 10685, 10690, 10691,
    10700, 10701, 10713, 10716, 10718, 10720, 10723, 10741, 10748, 10767, 10770, 10777, 10781,
    10783, 10785, 10794, 10801, 10802, 10803, 10804, 10806, 10807, 10809, 10810, 10812, 10817,
    10827, 10831, 10834, 10838, 10843, 10850, 10854, 10857, 10858, 10860, 10862, 10863, 10866,
    10875, 10887, 10896, 10898, 10908, 10918, 10924, 10930, 10938, 10940, 10950, 10952, 10953,
    10954, 10956, 10958, 10969, 10974, 10977, 10983, 10984, 11005, 11031
]

# Output file
fname = 'summary_task-trust_avg_trust_value_by_partner.csv'
output_file = os.path.join(outdir, fname)

# Initialize a list to store the results
results = []

for sub in sublist:
    trust_values = {
        'friend': [],
        'stranger': [],
        'computer': []
    }

    for r in range(2):
        input_file = os.path.join(rawdata, f'sub-{sub}', 'func', f'sub-{sub}_task-trust_run-{r + 1}_events.tsv')

        if os.path.exists(input_file):
            data = pd.read_csv(input_file, sep='\t')

            for partner in trust_values.keys():
                partner_trials = data[data['trial_type'].str.contains(f'outcome_{partner}', na=False)]
                trust_values[partner].extend(pd.to_numeric(partner_trials['trust_value'], errors='coerce').dropna())

    # Calculate average trust values for each partner type
    avg_trust_values = {partner: (sum(values) / len(values)) if values else None for partner, values in trust_values.items()}
    avg_trust_values['sub'] = f'sub-{sub}'
    
    results.append(avg_trust_values)

# Create a DataFrame from the results and save to CSV
results_df = pd.DataFrame(results)
results_df.to_csv(output_file, index=False)

print(f'Average trust values by partner saved to {output_file}')
