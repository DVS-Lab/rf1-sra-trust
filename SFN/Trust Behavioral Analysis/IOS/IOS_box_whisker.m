input_data = readtable("/Users/avidachs/Documents/GitHub/rf1-sra-data/v2.3_SFN_Covariates.xlsx");

% Extract the data for the three variables
friend_score = input_data.ios_friend_score;
stranger_score = input_data.ios_stranger_score;
computer_score = input_data.ios_computer_score;

% Combine the data into a cell array
data = {friend_score, stranger_score, computer_score};

% Create a box and whisker plot from a cell array of numeric vectors with different colors
figure;

% Specify the line width (thicker lines)
lineWidth = 2;

boxplot([friend_score, stranger_score, computer_score], ...
    'Labels', {'Friend', 'Stranger', 'Computer'})

% Add labels and title to the plot
xlabel('Variable');
ylabel('Score');
title('Inclusion of Other in Self');

% Optionally, customize the plot further if needed