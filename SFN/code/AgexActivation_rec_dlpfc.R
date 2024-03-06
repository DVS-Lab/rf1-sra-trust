library(readxl)
library(ggplot2)
library(broom)

# Read the data from the Excel file
file_path <- "/Users/coopersharp/Documents/GitHub/rf1-sra-trust/derivatives/imaging_plots/seed-dlPFC_model-age_type-act_cope-16_cname-rec_SocClose_subs.csv"
data <- read_csv(file_path)


# Fit a linear model
lm_model <- lm(activation ~ age, data)

#correlation coefficient
cor_coef <- cor(data$activation, data$age)

ggplot(data, aes(x = age, y = activation)) +
  geom_point() +
  stat_smooth(method = "lm", formula = y ~ x, color = "red", se = TRUE) +
  labs(title = paste("R =", round(cor_coef, 3), ""),
       x = "Age (years)",
       y = "dlPFC\nSocial Closeness Reciprocation (beta)") +
  theme(plot.title = element_text(hjust = 0.5, size = 18, face = "italic"), 
        axis.title.x = element_text(face = "bold", size = 18), 
        axis.title.y = element_text(face = "bold", size = 18), 
        legend.title = element_text(face = "bold", size = 18), 
        legend.text = element_text(size = 14),
        axis.text.x = element_text(size = 18, color = "black", face = "bold"),
        axis.text.y = element_text(size = 18, color = "black")) +
  geom_text(aes(label = paste("N =", nrow(data))), x = Inf, y = -Inf, hjust = 1.7, vjust = -33)
