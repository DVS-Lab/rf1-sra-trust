library(readxl)
library(ggplot2)
library(broom)

# Read the data from the CSV file
file_path <- "/Users/coopersharp/Desktop/dave_plots_age.csv"
data <- read.csv(file_path)

# Fit a linear model
lm_model <- lm(ecog_score ~ dudit_sum, data)

# Extract the sample size
sample_size <- nrow(data)

# Create the scatterplot with a line of best fit and error bars
ggplot(data, aes(x = dudit_sum, y = ecog_score)) +
  geom_jitter(alpha = 0.7, color = "black", size = 1.2) +  # Set color and size of the dots
  geom_point() +
  stat_smooth(method = "lm", formula = y ~ x, color = "blue", se = TRUE, linetype = "solid", size = 1.5) +
  geom_text(x = max(data$dudit_sum), y = min(data$ecog_score), label = paste("N =", sample_size), hjust = 1, vjust = 0) +
  labs(x = "DUDIT",
       y = "ECog") +
  theme(axis.text = element_text(size = 18),   # Set the font size for axis text
        axis.title = element_text(size = 18)) +  # Set the font size for axis titles
  scale_x_continuous(limits = c(min(data$dudit_sum), max(20))) +# Set x-axis limits # Set the font size for axis titles
  scale_y_continuous(limits = c(min(data$ecog_score), max(4)))
# Print the coefficient for the predictor variable "dudit_sum" to console
Rvalue <- cor(data$dudit_sum, data$ecog_score, use = "complete.obs")
sample_size <- sum(complete.cases(data$dudit_sum, data$ecog_score))
summary(lm_model)

