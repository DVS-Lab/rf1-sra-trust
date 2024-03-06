library(ggplot2)
library(dplyr)

# Read the data from the .tsv file
df <- read.delim("/Users/coopersharp/Documents/GitHub/rf1-sra-trust/code/tsnr_trust.tsv", header = TRUE, sep = "\t")
df <- na.omit(df)

# Extract echo number from 'sub' column
df$echo <- as.numeric(gsub(".*echo-(\\d+).*", "\\1", df$sub))
df$subid <- as.numeric(gsub(".*sub-(\\d+).*", "\\1", df$sub))

# Read the list of subject numbers from the CSV file
sub_list <- read.csv("/Users/coopersharp/Desktop/oldflip.csv", header = TRUE)

# Classify subjects into "new flip angle" and "old flip angle" groups
df <- df %>%
  mutate(group = ifelse(subid %in% as.numeric(sub_list$sub), "new flip angle", "old flip angle"))

df <- na.omit(df)
# Create the bar plot
ggplot(df, aes(x = factor(echo), y = mean, fill = group, na.rm = TRUE)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Average tSNR by Echo and Flip Angle", x = "Echo", y = "Average tSNR", fill = "Flip Angle") +
  scale_fill_manual(values = c("new flip angle" = "skyblue2", "old flip angle" = "lightgreen")) +
  theme_minimal()
