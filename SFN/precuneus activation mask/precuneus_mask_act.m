input_data = readtable("/Users/avidachs/Documents/GitHub/rf1-sra-trust/SFN/precuniusXage.xlsx");

% Extract the 'age' and 'precuneus_act' variables from the input_data table
age = input_data.age;
precuneus_act = input_data.precuneus_act;

% Define the custom color in RGB format (#ff6666)
customColor = [1.0, 0.4, 0.4];

% Create a scatter plot with custom color
scatter(age, precuneus_act, 100, 'Marker', 'o', 'MarkerFaceColor', customColor, 'MarkerEdgeColor', 'k');

% Label the axes
xlabel('Age');
ylabel('Precuneus Activity');

% Title for the plot (optional)
title('Fancy Scatter Plot of Age vs Precuneus Activity');

% Display the grid (optional)
grid on;