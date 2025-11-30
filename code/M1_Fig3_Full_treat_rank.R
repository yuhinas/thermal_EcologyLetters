# --------------------------------------------------------------------
# 1. Load Required Libraries
# --------------------------------------------------------------------
library(magrittr)   # For piping functionality (e.g., %>%) 
library(emmeans)    # For estimated marginal means and post-hoc tests
library(ggplot2)    # For data visualization
library(ggsignif)   # For adding significance bars to ggplot

# --------------------------------------------------------------------
# 2. Data Loading and Preparation
# --------------------------------------------------------------------

# Read the full dataset (individual-level data)
data_i <- read.csv("data/individual.csv")

# Convert the social rank variable (mi_hier) to a factor
data_i$mi_hier <- as.factor(data_i$mi_hier)

# --------------------------------------------------------------------
# 3. Model Fitting (M1)
# Response: mean_temp (Relative body temperature)
# Predictors: treat (Treatment) * mi_hier (Social Rank)
# --------------------------------------------------------------------

# Fit the linear model
model <- lm(mean_temp ~ treat * mi_hier, data=data_i)

# Summarize model to check basic statistics
summary(model)

# --------------------------------------------------------------------
# 4. Statistical Analysis (Post-hoc Tests)
# --------------------------------------------------------------------

# Comparison of treatments (treat) within each rank (mi_hier)
em_treat_within_rank <- emmeans(model, ~ treat | mi_hier) %>% pairs()

# Comparison of ranks (mi_hier) within each treatment (treat)
em_rank_within_treat <- emmeans(model, ~ mi_hier | treat) %>% pairs()

# --------------------------------------------------------------------
# 5. Visualization
# --------------------------------------------------------------------

figure_3 <- ggplot(data=data_i, aes(x=mi_hier, y=mean_temp, fill=treat)) +
  # Box plots
  geom_boxplot(position = "dodge") +
  
  # Manual color scaling and labels
  scale_fill_manual(
    name = "Treatment", 
    labels = c("maggot" = "blowfly"),
    values = c("control" = "grey", "maggot" = "dimgray")
  ) +
  
  # Classic theme and axis labels
  theme_classic() +
  labs(x = "Social Rank", y = "Relative body temperature (°C)") +
  
  # Coordinate limits and expansion
  coord_cartesian(ylim = c(-1, 7), expand = TRUE) +
  
  # Add significance bars (Hard-coded for final figure aesthetics)
  geom_signif(
    y_position = c(5.55, 5.55, 6, 6.45), 
    xmin = c(0.8, 1.8, 1.8, 0.8), 
    xmax = c(1.2, 2.2, 2.8, 2.8),
    annotation = c("*", "*", "*", "***"), 
    tip_length = 0, 
    size = 0.8, 
    textsize = 7, 
    vjust = 0.4
  ) +
  
  # Adjust text size for the entire plot
  theme(text = element_text(size = 21)) +
  
  # Custom x-axis labels (Rank 1, 2, 3 to Greek letters)
  scale_x_discrete(labels = c("1" = "α", "2" = "β", "3" = "γ"))

# Display and save the figure
print(figure_3)

