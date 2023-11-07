input_data = readtable("/Users/avidachs/Documents/GitHub/rf1-sra-data/v2.3_SFN_Covariates.xlsx");

% Extract the 'sub_age' and 'oafem_total' columns
sub_age = input_data.sub_age;
precuneus_mask_activation = input_data.oafem_total;

% Create a scatter plot without 'filled'
scatter(sub_age, oafem_total);
title('Scatter Plot of sub_age vs. oafem_total');
xlabel('age');
ylabel('Precuneus Activation');
grid on;

% Fit a linear regression line
coefficients = polyfit(sub_age, oafem_total, 1);
line_fit = polyval(coefficients, sub_age);

% Add the line of best fit to the plot
hold on;
plot(sub_age, line_fit, 'r', 'LineWidth', 2); % Decreased line width
legend('Data', 'Line of Best Fit');
hold off;

disp(class(sub_age));
disp(class(oafem_total));