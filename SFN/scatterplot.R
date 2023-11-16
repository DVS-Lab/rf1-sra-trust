library(readxl)
library(ggplot2)
library(broom)

# Read the data from the Excel file
file_path <- "/Users/avidachs/Documents/GitHub/rf1-sra-trust/SFN/covariates/oafemScatter.xlsx"
data <- read_excel(file_path)


# Fit a linear model
lm_model <- lm(oafem ~ age, data)

#correlation coefficient
cor_coef <- cor(data$oafem, data$age)

# Create the scatterplot with a line of best fit and error bars
ggplot(data, aes(x = age, y = oafem)) +
  geom_point() +
  stat_smooth(method = "lm", formula = y ~ x, color = "red", se = TRUE) +
  labs(title = paste("Scatterplot (Correlation: ", round(cor_coef, 3), ")"),
       x = "age",
       y = "c16")

summary(lm_model)
