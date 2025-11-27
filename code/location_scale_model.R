# location_scale_model.R
# --------------------------------------------------------------------
# 1. Load Required Libraries
# --------------------------------------------------------------------
library(magrittr)   # For piping functionality (e.g., %>%)
library(glmmTMB)    # For Generalized Linear Mixed Models with TMB, including location-scale models
library(emmeans)    # For Estimated Marginal Means
library(ggplot2)    # For data visualization
library(ggsignif)   # For adding significance bars to ggplot
# --------------------------------------------------------------------
# 2. Data Loading and Preparation
# --------------------------------------------------------------------

data_i <- read.csv("data/individual.csv")

# Convert the social rank variable (mi_hier) to a factor
data_i$mi_hier <- as.factor(data_i$mi_hier)

# --------------------------------------------------------------------
# 3. Model Fitting (Location-Scale GLMM)
# --------------------------------------------------------------------

## Location-Scale GLMM (using Gaussian family for mean_temp)
m_ls <- glmmTMB(
  mean_temp ~ treat * mi_hier, # Location (Mean) Component: treat * mi_hier interaction
  dispformula = ~ treat * mi_hier, # Scale (Variance) Component: treat * mi_hier interaction
  family = gaussian,
  data = data_i
)

# Display model summary (shows location coefficients and disp. (log-variance) coefficients)
summary(m_ls)

# --------------------------------------------------------------------
# 4. Statistical Analysis (Post-hoc Tests)
# --------------------------------------------------------------------

# Post-hoc comparisons for the location component (mean_temp)

# Compare treatments (control vs. blowfly) within each social rank
em_treat_by_rank <- emmeans(m_ls, ~ treat | mi_hier, type = "response") %>% pairs()
print("--- Treat Comparison within Rank (Location) ---")
print(em_treat_by_rank)

# Compare social ranks (alpha vs. beta vs. gamma) within each treatment group
em_rank_by_treat <- emmeans(m_ls, ~ mi_hier | treat, type = "response") %>% pairs()
print("--- Rank Comparison within Treat (Location) ---")
print(em_rank_by_treat)

# --------------------------------------------------------------------
# 5. Visualization (Figure S7)
# Plotting Estimated Marginal Means (EMMs) of the Location Component
# --------------------------------------------------------------------

# Extract Estimated Marginal Means from the model
emm <- emmeans(m_ls, ~ treat * mi_hier, type = "response") %>% as.data.frame()

# Calculate error bar bounds based on Standard Error (SE)
emm$lower <- emm$emmean - emm$SE
emm$upper <- emm$emmean + emm$SE

figure_S7 <- ggplot(data = emm, aes(x = mi_hier, y = emmean, fill = treat)) +
  # Column plots for EMMs
  geom_col(position = "dodge") +
  
  # Error bars (based on SE)
  geom_errorbar(aes(ymin = lower, ymax = upper), 
                width = .1, 
                position = position_dodge(.9)) +
  
  theme_classic() +
  theme(text = element_text(size = 21)) +
  
  # Custom fill colors and labels (enforcing lower case labels)
  scale_fill_manual(
    name = "Treatment",
    values = c("control" = "grey", "maggot" = "dimgray"),
    labels = c("control" = "control", "maggot" = "blowfly")
  ) +
  
  labs(x = "Social Rank", y = "Relative body temperature (°C)") +
  
  # Add significance bars (Hard-coded from post-hoc results)
  geom_signif(
    y_position = c(2.1, 2.3, 2.5), 
    xmin = c(0.78, 1.78, 0.78), 
    xmax = c(1.22, 2.78, 2.78),
    annotation = c("*", "*", "***"), 
    tip_length = 0, 
    size = 1, 
    textsize = 9, 
    vjust = 0.4
  ) +
  
  ylim(0, 3) +
  
  # Custom x-axis labels
  scale_x_discrete(labels = c("1" = "α", "2" = "β", "3" = "γ"))


print(figure_S7)
