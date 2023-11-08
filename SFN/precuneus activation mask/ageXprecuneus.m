input_data = readtable("/Users/avidachs/Documents/GitHub/rf1-sra-trust/SFN/ACC activation mask/iosXacc(model2).xlsx");

% Extract the 'age' and 'precuneus_act' variables from the input_data table
ios = input_data.ios;
acc_act = input_data.acc_act;

% Define the custom color in RGB format (#ff6666)
customColor = [1.0, 0.4, 0.4];

% Create a scatter plot with custom color
scatter(ios, acc_act, 100, 'Marker', 'o', 'MarkerFaceColor', customColor, 'MarkerEdgeColor', 'k');

% Label the axes
xlabel('IOS');
ylabel('ACC Activity');

% Title for the plot (optional)
title('IOS vs ACC Activity');

% Display the grid (optional)
grid on;