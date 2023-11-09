library(readxl)
library(ggplot2)
library(broom)

# Read the data from the Excel file
file_path <- "/Users/avidachs/Documents/GitHub/rf1-sra-trust/SFN/Trust Behavioral Analysis/OAFEM/oafemScatter.xlsx"
data <- read_excel(file_path)

# Fit a linear model
lm_model <- lm(oafem ~ fc_ios, data)

# Create the scatterplot with a line of best fit and error bars
ggplot(data, aes(x = fc_ios, y = oafem)) +
  geom_point() +
  stat_smooth(method = "lm", formula = y ~ x, color = "blue", se = TRUE, linetype = "dotted") +
  labs(title = "Scatterplot",
       x = "IOS F-C",
       y = "OAFEM")

summary(lm_model)
