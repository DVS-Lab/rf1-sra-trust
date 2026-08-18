import pandas as pd

# Read data from a CSV file (replace 'data.csv' with your file path)
df = pd.read_csv('data.csv')

# Function to determine if a participant chose to share more with a friend
def chose_higher_with_friend(row):
    if row['partner'] == 3:  # Friend
        return row['choice_1'] > row['choice_2']
    else:
        return False

# Apply the function to each row and calculate the frequency
df['chose_higher_with_friend'] = df.apply(chose_higher_with_friend, axis=1)
frequency = df['chose_higher_with_friend'].mean()

print(f"The frequency of choosing more with a friend than a stranger or computer: {frequency:.2%}")
