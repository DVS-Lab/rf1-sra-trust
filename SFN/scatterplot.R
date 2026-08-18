library(readxl)
library(ggplot2)
library(broom)

# Read the data from the Excel file
file_path <- "/Users/coopersharp/Documents/GitHub/rf1-sra-trust/derivatives/imaging_plots/seed-VS_model-4_type-act_cope-10_cname-rec-def_subs.csv"
data <- read_csv(file_path)


# Fit a linear model
lm_model <- lm(activation ~ age, data)

#correlation coefficient
cor_coef <- cor(data$activation, data$age)

# Create the scatterplot with a line of best fit and error bars
ggplot(data, aes(x = age, y = activation)) +
  geom_point() +
  stat_smooth(method = "lm", formula = y ~ x, color = "red", se = TRUE) +
  labs(title = paste("Scatterplot (Correlation: ", round(cor_coef, 3), ")"),
       x = "age",
       y = "activation")

summary(lm_model)
