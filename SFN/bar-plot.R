library(ggplot2)
library(readxl)   # For reading Excel files


data <- read_xlsx("/Users/avidachs/Documents/GitHub/rf1-sra-trust/SFN/covariates/Trust_Full_Covariates.xlsx")

ggplot(data, aes(x = factor(1), y = ios_friend_score)) +
  geom_bar(stat = "identity", position = "dodge", fill = "blue") +
  geom_errorbar(aes(ymin = ios_friend_score - se_ios_friend_score, ymax = ios_friend_score + se_ios_friend_score), width = 0.2) +
  geom_bar(aes(x = factor(2), y = ios_stranger_score), stat = "identity", position = "dodge", fill = "green") +
  geom_errorbar(aes(x = factor(2), ymin = ios_stranger_score - se_ios_stranger_score, ymax = ios_stranger_score + se_ios_stranger_score), width = 0.2) +
  geom_bar(aes(x = factor(3), y = ios_computer_score), stat = "identity", position = "dodge", fill = "red") +
  geom_errorbar(aes(x = factor(3), ymin = ios_computer_score - se_ios_computer_score, ymax = ios_computer_score + se_ios_computer_score), width = 0.2) +
  labs(title = "Bar Graph with Error Bars", x = NULL, y = "Scores") +
  theme_minimal()