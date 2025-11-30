# --------------------------------------------------------------------
# 1. Load Required Libraries
# --------------------------------------------------------------------
library(ggplot2)    # For data visualization
library(ggsignif)   # For adding significance bars to ggplot
# --------------------------------------------------------------------
# 2. Data Loading and Preparation
# --------------------------------------------------------------------

# Read the full dataset (individual-level data)
data_i <- read.csv("data/individual.csv")

# --------------------------------------------------------------------
# 3. Model Fitting (M8)
# Response: max_temp_time (Time to reach maximum relative body temperature)
# Predictors: treat (Treatment)
# --------------------------------------------------------------------

# Fit the linear model
m <- lm(max_temp_time ~ treat, data = data_i)

# Display model summary (Coefficients and p-values)
summary(m)

# --------------------------------------------------------------------
# 4. Visualization (Figure 2D)
# Plots the predicted mean +/- SE based on the model 'm'.
# --------------------------------------------------------------------

# Create a data frame for prediction
xv <- data.frame(treat = c("control", "maggot"))

# Get predicted values (fit) and standard errors (se.fit) from the model
yv <- data.frame(predict(m, xv, type = "response", se.fit = TRUE), xv)

# Calculate upper and lower bounds for the standard error (SE) error bars
yv$upper <- yv$fit + yv$se.fit
yv$lower <- yv$fit - yv$se.fit

figure_2D <- ggplot(data = yv, aes(x = treat, y = fit, fill = treat)) +
  # Bar plots for predicted means
  geom_col(position = "dodge") +
  
  # Manual color scaling and labels
  scale_fill_manual(
    name = "Treatment", 
    values = c("control" = "grey", "maggot" = "dimgray"),
    labels = c("control" = "control", "maggot" = "blowfly")
  ) +
  
  # Classic theme and text size adjustment
  theme_classic() +
  theme(text = element_text(size = 21)) + 
  
  # Error bars (based on SE)
  geom_errorbar(aes(ymin = lower, ymax = upper), 
                width = .1, 
                position = position_dodge(.9)) +
  
  # Custom x-axis labels
  scale_x_discrete(labels = c("maggot" = "blowfly")) +
  
  # Axis labels
  labs(x = "", y = "Time to reach maximum relative body temperature (hours)") +
  
  # Add significance bar (Hard-coded for final figure aesthetics）
  geom_signif(
    y_position = c(1.1), 
    xmin = c(1), 
    xmax = c(2), 
    annotation = c("**"), 
    tip_length = 0, 
    size = 0.8, 
    textsize = 7, 
    vjust = 0.3
  )

# Display the figure
print(figure_2D)

