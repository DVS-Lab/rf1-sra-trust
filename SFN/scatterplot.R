library(readxl)
library(ggplot2)
library(broom)

# Read the data from the Excel file
file_path <- "/Users/avidachs/Documents/GitHub/rf1-sra-trust/SFN/Images/Graphs/Whole Brain Activation X Age/activationXageC16.xlsx"
data <- read_excel(file_path)

# Fit a linear model
lm_model <- lm(c17 ~ age, data)

# Create the scatterplot with a line of best fit and error bars
ggplot(data, aes(x = age, y = c17)) +
  geom_point() +
  stat_smooth(method = "lm", formula = y ~ x, color = "red", se = TRUE) +
  labs(title = "Scatterplot",
       x = "age",
       y = "C10")

summary(lm_model)
