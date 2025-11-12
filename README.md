# Interspecific competition reduces energy expenditure by decreasing intragroup conflict in a social burying beetle

This repository contains the R code and analysis scripts supporting the manuscript.

The code provided here allows for the full reproduction of all core statistical models and figures presented in the main text and the supplementary material.

---

## 📋 Repository Structure

| File Name | Content |
| :--- | :--- |
| `body_temp.csv` | **Time-Series Data**: Detailed records of individual relative body temperature over time. |
| `individual.csv` | **Individual-Level Data**: Summary data including body temperature, social rank, sex, treatment group (Control/Blowfly), and aggregated behavioral variables. |
| `behavior.csv` | **Behavioral Time-Series Data**: Detailed time-series records of cooperative investment and conflict behavior across 10 time intervals. |
| `*.R` | **Analysis Scripts**: Contains all code for model fitting and figure generation. |

## 📦 Running Environment and Required Packages (R Packages)

All analyses were performed in the R environment. Please ensure you have the following essential packages installed and loaded:

```R
# Core Data Manipulation and Visualization
library(dplyr)
library(ggplot2)
library(magrittr)
library(tidyr)      # For data reshaping (gather/pivot_longer)

# Linear Models and GLMM
library(car)        # For Type III ANOVA
library(emmeans)    # For Post-hoc comparisons
library(glmmTMB)    # For Location-Scale GLMM (Figure S7)
library(ggsignif)   # For adding significance bars

# Advanced Models and Smoothing
library(mgcv)       # For Generalized Additive Models (GAM) (Figs 2A, 2B, S1, S2, S5, S6)
library(piecewiseSEM) # For Structural Equation Modeling (SEM.R)
