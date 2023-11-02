# Install and load the required packages
if (!requireNamespace("tidyverse", quietly = TRUE)) {
  install.packages("tidyverse")
}
library(tidyverse)

# Install and load the 'broom' package
if (!requireNamespace("broom", quietly = TRUE)) {
  install.packages("broom")
}
library(broom)


# Read the CSV file
data <- read.csv("/Users/avidachs/Desktop/Trust Behavioral/IOS_new.csv")

# Check the structure of your data
str(data)

# If 'measure' is a factor, convert it to character
data$measure <- as.character(data$measure)

# Perform ANOVA
anova_result <- aov(value ~ measure, data = data)

# Tidy the ANOVA results
tidy_anova <- broom::tidy(anova_result)

# Display the ANOVA results
print(tidy_anova)


# Create a box-and-whisker plot
ggplot(data, aes(x = measure, y = value)) +
  geom_boxplot() +
  labs(x = "Measure", y = "Value") +
  ggtitle("Box-and-Whisker Plot of the Data")

# Create a fancier box-and-whisker plot
ggplot(data, aes(x = measure, y = value, fill = measure)) +
  geom_boxplot(outlier.shape = NA, width = 0.5, alpha = 0.7) +
  geom_jitter(width = 0.1, alpha = 0.5, color = "black") +
  scale_fill_manual(values = c("ios_stranger" = "lightblue", "ios_friend" = "lightgreen", "ios_computer" = "lightcoral")) +
  labs(x = "Measure", y = "Value") +
  ggtitle("Fancy Box-and-Whisker Plot of the Data") +
  theme_minimal() +
  theme(legend.position = "none")