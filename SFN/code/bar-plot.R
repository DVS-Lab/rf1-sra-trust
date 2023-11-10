
library(ggplot2)
library(readxl)

# Read the data from the Excel file
data <- read_xlsx("/Users/avidachs/Documents/GitHub/rf1-sra-trust/SFN/Trust Behavioral Analysis/IOS/IOS.xlsx")

# Check the column names in your data
colnames(data)

# Create a bar plot with error bars
ggplot(data, aes(x = Friend)) +
  geom_bar(aes(y = x), stat = "identity", fill = "lightblue", width = 0.5) +
  geom_errorbar(aes(ymin = x - SE, ymax = x + SE), width = 0.2) +
  labs(x = "Groups", y = "Mean", title = "Mean and Standard Error Bar Plot") +
  theme_minimal()