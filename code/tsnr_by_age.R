library(ggplot2)
library(dplyr)

# Read the data from the .tsv file
df <- read.delim("/Users/coopersharp/Documents/GitHub/rf1-sra-trust/code/tsnr_trust_VS.tsv", header = TRUE, sep = "\t")
df <- na.omit(df)


# Extract subid from 'sub' column
df$subid <- as.numeric(gsub(".*sub-(\\d+).*", "\\1", df$sub))
df$echo <- as.numeric(gsub(".*echo-(\\d+).*", "\\1", df$sub))

# Filter data where echo = 1
df <- df %>%
  filter(echo == 1)

# Calculate mean tSNR for each subject
subject_summary <- df %>%
  group_by(subid) %>%
  summarize(mean_tsnr = mean(meanVS))

# Read the list of subject numbers and ages from the CSV file
age_data <- read.csv("/Users/coopersharp/Desktop/age_tsnr.csv", header = TRUE)

# Merge age data with subject_summary based on subid
subject_summary <- merge(subject_summary, age_data, by = "subid")

# Create the scatterplot with regression line
ggplot(subject_summary, aes(x = age, y = mean_tsnr)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Mean of tSNR for Echo 1 for Each Subject", x = "Age", y = "Mean of VS tSNR") +
  theme_minimal()

# Calculate correlation coefficient
correlation <- cor(subject_summary$age, subject_summary$mean_tsnr)
print(paste("Correlation coefficient:", round(correlation, 2)))
