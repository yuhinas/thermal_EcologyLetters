# Interspecific competition reduces energy expenditure by decreasing intragroup conflict in a social burying beetle

[![DOI](https://zenodo.org/badge/958470137.svg)](https://doi.org/10.5281/zenodo.17769641)

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

## 📑 Data Dictionary (Variables, Definitions, Units)

Below we provide a full variable-level metadata table for all data files included in the repository.  
For each dataset, we list the variable name, definition, and units.

### **1. `body_temp.csv`**

| Variable | Description | Unit |
|---------|--------------|------|
| Date_dmy | Date of measurement | DD-MM-YYYY |
| Time_Relative_sf | The relative time between the measurement time and the start time of the experiment | Seconds|
| Observation | Records the unique identification number of the nest | n xxxx |
| Subject | Records the unique identification tag of the individual within its specific nest | (sex, mark) |
|Tb | The body temperature of the beetle | °C |
|Ta | The average temperature across the entire field of view | °C |
|Tc | The temperature of carcass |°C |
|Ts | The temperature of soil |°C |
|Tb.Ta |Tb-Ta|°C |
|Tb.Tc |Tb-Tc , we use this value as relative body temperature. |°C |
|Tb.Ts|Tb-Ts|°C |
|treat| Experimental treatment | control / maggot (blowfly)|
|mi_hier| Social rank | 1 for alpha, 2 for beta , 3 for gamma |
|mark| The label of the beetle | the mark pattern |
|nm| Records the unique identification number of the individual across all nests in the entire dataset | (nest number, mark)|

### **2. `individual.csv`**

| Variable | Description | Unit |
|---------|--------------|------|
|nm| Records the unique identification number of the individual across all nests in the entire dataset | (nest number, mark)|
|nest| Records the unique identification number of the nest | n xxxx |
|treat| Experimental treatment | control / maggot (blowfly)|
|gender| Individual sex | male / female|
|i_width| The width of the pronotum| mm|
|i_weight| Individual body weight | mg|
|i_body| Body weight divided by pronotum width | mg/mm |
|i_BMI| Body weight / (pronotum width)^2 | mg/mm^2 |
|i_age| Age of the beetle| days|
|i_mark| The label of the beetle | the mark pattern |
|i_invest| Individual investment time| seconds|
|mi_hier| Social rank | 1 for alpha, 2 for beta , 3 for gamma |
|i_conflict| Number of social conflicts| times|
|mean_temp| Average of relative body temperature | °C |
|max_temp| The maximum of relative body temperature |°C |
|temp_range| The temperature range between the maximun and the minimum of relative body temperature|°C |
|group_size| Average group size of the nest| number of beetles|
|i_wrestle.num| The total count of 'wrestle' behaviors performed by the individual | times |
|i_attack.num|The total count of 'attack' behaviors performed by the individual | times |
|i_chase.num|The total count of 'chase' behaviors performed by the individual | times |
|i_escape.num|The total count of 'escape' behaviors performed by the individual | times |
|Tb | The body temperature of the beetle | °C |
|conflict_invest| i_conflict / i_invest | times/seconds|
|attack_invest|i_attack / i_invest | times/seconds|
|wrestle_invest|i_wrestle / i_invest | times/seconds|
|chase_invest|i_chase / i_invest | times/seconds|
|escape_invest|i_escape / i_invest | times/seconds|
|Tc | The temperature of carcass |°C |

### **3. `behavior.csv`**

| Variable | Description | Unit |
|---------|--------------|------|
|nm| Records the unique identification number of the individual across all nests in the entire dataset | (nest number, mark)|
|attack_i <br> (where i = = 1 to 10)| The total count of 'attack' behaviors recorded during the $i^{th}$ hour of the observation period| times|
|wrestle_i <br> (where i = = 1 to 10)| The total count of 'wrestle' behaviors recorded during the $i^{th}$ hour of the observation period| times|
|chase_i <br> (where i = = 1 to 10)| The total count of 'chase' behaviors recorded during the $i^{th}$ hour of the observation period| times|
|escape_i <br> (where i = = 1 to 10)| The total count of 'escape' behaviors recorded during the $i^{th}$ hour of the observation period| times|
|conflict_i <br> (where i = = 1 to 10)| The number of social conflicts recorded during the $i^{th}$ hour of the observation period| times|
|investment_i <br> (where i = = 1 to 10)| The indiviual investment time recorded during the $i^{th}$ hour of the observation period| seconds|

## 📦 Running Environment and Required Packages (R Packages)

All analyses were performed in the R environment. 
The manuscript results were generated under the following versions:

### **R Version**
- R **4.5.1**

### **Package Versions**
Exact package versions used in the analysis:
- dplyr 1.1.4
- ggplot2 3.5.2
- magrittr 2.0.3
- tidyr 1.3.1
- car 3.1-3
- emmeans 1.11.1
- glmmTMB 1.1.11
- ggsignif 0.6.4
- mgcv 1.9-3
- piecewiseSEM 2.3.1

### **Required libraries**

```R
# Core Data Manipulation and Visualization
library(dplyr)
library(ggplot2)
library(magrittr)
library(tidyr)      # For data reshaping (gather/pivot_longer)

# Linear Models and GLMM
library(car)        # For Type II and Type III ANOVA
library(emmeans)    # For Post-hoc comparisons
library(glmmTMB)    # For Location-Scale GLMM (Figure S7)
library(ggsignif)   # For adding significance bars

# Advanced Models and Smoothing
library(mgcv)       # For Generalized Additive Models (GAM) (Figs 2A, 2B, S1, S2, S5, S6)
library(piecewiseSEM) # For Structural Equation Modeling (SEM.R)
```
---

## 📊 Analysis Scripts Index (Core Models & Figures)

This section links each R script file to the corresponding figure and statistical model (M1-M10, SEM, GLMM) in the manuscript.

### 1. Thermal Physiology (LM & GAM)

| Script Name | Figure and Table | Core Model | Key Analysis |
| :--- | :--- | :--- | :--- |
| `Fig2A_2B_GAM.R` | **Figure 2A, 2B** <br> **Table S1, S2** | GAM | Smooth trends of relative body temperature over time, colored by treatment and rank/sex. |
| `M3_Fig2C_Full_treatment.R` | **Figure 2C** | **M3** | relative body temperature vs. Treatment (Full night). |
| `M8_Fig2D_time.R` | **Figure 2D** | **M8** | Time to reach maximum relative body temperature vs. Treatment Group. |
| `M1_Fig3_Full_treat_rank.R` | **Figure 3** | **M1** | Relative body temperature vs. Treatment $\times$ Social Rank interaction. |
| `M2_FigS8_body_size.R` | **Figure S8** <br> **Table S5** | **M2** | Relative body temperature vs. Treatment $\times$ Rank + Body Size. |
| `FigS1_S2_GAM.R` | **Figure S1, S2** | GAM | Scatter plots and GAM smooth lines for relative body temperature over time for each individual Rank/Sex subgroup. |
| `M4_FigS3_Half_treatment.R` | **Figure S3A, S3B** | **M4-1, M4-2** | Relative body temperature vs. Treatment (First/Second Half). |
| `M5_FigS4_social_rank.R` | **Figure S4A-S4D** | **M5-C1, C2, B1, B2** | Relative body temperature vs. Social Rank (Split by Treatment and Time Half). |

### 2. Behavior & Interaction (LM & GAM)

| Script Name | Figure and Table | Core Model | Key Analysis |
| :--- | :--- | :--- | :--- |
| `M6_M7_Fig4_cooperation.R` | **Figure 4A-4D** | **M6, M7** | Partial regression plots of relative body temperature vs. Investment and Conflict Index. |
| `M9_M10_Fig4E_4F_behavior.R`| **Figure 4E, 4F** | **M9, M10** | Total Cooperative Investment and Conflict Index vs. Treatment Group. |
| `FigS5_S6_GAM_behavior.R` | **Figure S5, S6** | GAMs | Smooth trends of Cooperative Investment and Conflict behavior across 10 time intervals. |

### 3. Advanced Statistical Models

| Script Name | Figure and Table | Core Model | Description |
| :--- | :--- | :--- | :--- |
| `location_scale_model.R`| **Figure S7** <br> **Table S4**| **GLMM (Location-Scale)** | Analyzes the effects of Treatment and Rank on the **Mean** (location) and **Variance** (scale) of relative body temperature. |
| `SEM.R` | **Figure 5** | **pSEM** | Piecewise Structural Equation Model testing the causal pathways among Treatment, Behavior (Conflict/Investment), and relative body temperature. |

#### Note on Figure 5 (SEM path diagram)

The numerical results underlying Figure 5 (standardized path coefficients, standard errors, and p-values) are fully reproducible from `SEM.R`. 

However, the **published Figure 5 graphic itself was assembled manually in Adobe Illustrator**, using these numerical outputs (to improve visual clarity over default plotting functions). Therefore, there is no R script that reproduces the exact final layout of the Figure 5 panel, but all underlying statistics are reproducible from the provided code and data.
