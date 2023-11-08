library(readxl)
library(ggplot2)
library(broom)

# Read the data from the Excel file
file_path <- "/Users/avidachs/Documents/GitHub/rf1-sra-trust/SFN/Trust Behavioral Analysis/trustBehavior.csv"
data <- read.csv(file_path)

# Fit a linear model
lm_model <- lm(fs ~ age, data)

# Create the scatterplot with a line of best fit and error bars
ggplot(data, aes(x = age, y = fs)) +
  geom_point() +
  stat_smooth(method = "lm", formula = y ~ x, color = "blue", se = TRUE, linetype = "dotted") +
  labs(title = "Scatterplot of Age vs. iosF_C with Error Bars",
       x = "Age",
       y = "iosF_C")

summary(lm_model)
