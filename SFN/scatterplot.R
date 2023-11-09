library(readxl)
library(ggplot2)
library(broom)

# Read the data from the Excel file
file_path <- "/Users/avidachs/Documents/GitHub/rf1-sra-trust/SFN/C10Xfs.xlsx"
data <- read_xlsx(file_path)

# Fit a linear model
lm_model <- lm(C10 ~ f-s, data)

# Create the scatterplot with a line of best fit and error bars
ggplot(data, aes(x = f-s, y = C10)) +
  geom_point() +
  stat_smooth(method = "lm", formula = y ~ x, color = "blue", se = TRUE, linetype = "dotted") +
  labs(title = "Scatterplot of Age vs. iosF_C with Error Bars",
       x = "f-s",
       y = "Cope10")

summary(lm_model)
