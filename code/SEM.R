# --------------------------------------------------------------------
# 1. Load Required Libraries
# --------------------------------------------------------------------
library(piecewiseSEM) # For fitting and analyzing piecewise Structural Equation Models (pSEM)
# --------------------------------------------------------------------
# 2. Data Loading and Preparation
# --------------------------------------------------------------------

data_i <- read.csv("individual.csv")

# Convert the categorical 'treat' variable into a numeric dummy variable for SEM
data_i$treat <- ifelse(data_i$treat == "control", 1, 2)

# --------------------------------------------------------------------
# 3. Structural Equation Model (pSEM)
# --------------------------------------------------------------------

# Define the pSEM structure using the psem() function, which takes a list of lm() models

mod <- psem(
  # Equation 1: Predicts the primary response variable (mean_temp)
  # mean_temp ~ Conflict Index + Treatment + Individual Investment
  lm(mean_temp ~ conflict_invest + treat + i_invest, data = data_i),
  
  # Equation 2: Predicts individual investment (i_invest)
  # i_invest ~ Treatment + ambient temperature (Tc)
  lm(i_invest ~ treat + Tc, data = data_i),
  
  # Equation 3: Predicts conflict index (conflict_invest)
  # conflict_invest ~ Individual Investment + Treatment
  lm(conflict_invest ~ i_invest + treat, data = data_i),
  
  data = data_i
)

# Summarize the pSEM results
# The summary provides:
# 1. Coefficients and R-squared for each component model (lm)
# 2. Tests of Directed Separation (conditional independence)
# 3. Model fit statistics (e.g., Fisher's C, AIC)

summary(mod)

# Note: The published Figure 5 diagram itself (arrows and boxes) was assembled manually in Adobe Illustrator using the numerical outputs from this script. Hence, there is no R code that reproduces the exact graphical layout of Figure 5, but all statistics are fully reproducible.
