# --------------------------------------------------------------------
# 1. Load Required Libraries
# --------------------------------------------------------------------
library(mgcv)       # For Generalized Additive Models (GAM)
library(ggplot2)    # For data visualization
library(dplyr)
# --------------------------------------------------------------------
# 2. Data Loading and Preparation
# --------------------------------------------------------------------
data_t <- read.csv("data/body_temp.csv")
data_i <- read.csv("data/individual.csv")

# Select only necessary columns from individual data (nm, gender)
data_i <- data_i[, c("nm", "gender")]

# Merge time-series data with individual data
data_t <- merge(data_t, data_i, all.x = TRUE, by = "nm") 

# Create a combined factor for grouping
data_t$group <- paste(data_t$gender, data_t$mi_hier)

# Separate data by treatment group
data_m <- subset(data_t, data_t$treat == "maggot") # Blowfly group
data_c <- subset(data_t, data_t$treat == "control") # Control group

# --------------------------------------------------------------------
# 3. Statistical analysis for Supplementary Tables S1 and S2
# --------------------------------------------------------------------

# Split dataset by group
list_of_groups_control <- split(data_c, data_c$group)
list_of_groups_maggot  <- split(data_m, data_m$group)

# Function to fit GAM and extract the exact statistics for Table S1/S2
run_gam_and_extract <- function(dat, group_name, treatment_label) {
  
  # Fit model
  m <- gam(Tb.Tc ~ s(Time_Relative_sf, bs = "cs"), data = dat)
  
  # Extract smooth-term table from summary()
  s_tab <- summary(m)$s.table
  smooth_row <- s_tab[1, , drop = FALSE]
  
  # Extract edf, F, p
  edf_val <- as.numeric(smooth_row[, "edf"])
  F_val   <- as.numeric(smooth_row[, "F"])
  p_val   <- as.numeric(smooth_row[, "p-value"])
  
  # Format p exactly (never show 0)
  # eps = minimal threshold; values smaller than eps displayed as "< 1e-16"
  p_formatted <- format.pval(
    p_val,
    digits = 4,
    eps    = 1e-16,     # scientific notation for extremely small p-values
    scientific = TRUE
  )
  
  # Build table row
  data.frame(
    Term      = "s(Time_Relative_sf)",
    Treatment = treatment_label,
    Group     = group_name,
    edf       = round(edf_val, 3),
    F         = signif(F_val, 4),
    p         = p_formatted,
    row.names = NULL
  )
}

# ---- Build Table S1 (Control group) ------------------------------------------
table_S1 <- bind_rows(
  lapply(names(list_of_groups_control), function(g) {
    run_gam_and_extract(
      dat             = list_of_groups_control[[g]],
      group_name      = g,
      treatment_label = "Control"
    )
  })
)

# ---- Build Table S2 (Blowfly treatment group) --------------------------------
table_S2 <- bind_rows(
  lapply(names(list_of_groups_maggot), function(g) {
    run_gam_and_extract(
      dat             = list_of_groups_maggot[[g]],
      group_name      = g,
      treatment_label = "Blowfly"
    )
  })
)

# Display for inspection
table_S1
table_S2

# --------------------------------------------------------------------
# 4. Visualization (Figure 2A & 2B)
# Plotting the GAM-smoothed time course of relative body temperature
# --------------------------------------------------------------------

# Define shared color and label scheme
color_scheme <- c("#dc143c", "#fa8072", "#90EE90", "#008b8b", "#00ced1", "#afeeee")
label_scheme <- c("♀ α", "♀ β", "♀ γ", "♂ α", "♂ β", "♂ γ")

# --- Figure 2A: Control Group ---
figure_2A <- ggplot(data = data_c, aes(x = Time_Relative_sf / 3600, y = Tb.Tc, color = group)) +
  # Plot GAM smooth curve
  geom_smooth(method = "gam", se = FALSE, formula = y ~ s(x, bs = "cs")) +
  
  # Manual color scale and labels (Social Rank + Gender)
  scale_color_manual(
    name = "",
    values = color_scheme,
    labels = label_scheme
  ) +
  
  theme_classic() +
  theme(text = element_text(size = 15)) +
  labs(x = "Time", y = "Relative body temperature (°C)") +
  
  # Custom x-axis breaks and labels (converting seconds to time clock)
  scale_x_continuous(
    breaks = c(0.0, 2.5, 5.0, 7.5, 10.0), 
    labels = c("19:00", "21:30", "00:00", "02:30", "05:00") 
  ) +
  coord_cartesian(ylim = c(-0.5, 3), expand = TRUE)

print(figure_2A)

# --- Figure 2B: Blowfly Group ---
figure_2B <- ggplot(data = data_m, aes(x = Time_Relative_sf / 3600, y = Tb.Tc, color = group)) +
  # Plot GAM smooth curve
  geom_smooth(method = "gam", se = FALSE, formula = y ~ s(x, bs = "cs")) +
  
  # Manual color scale and labels
  scale_color_manual(
    name = "",
    values = color_scheme,
    labels = label_scheme
  ) +
  
  theme_classic() +
  theme(text = element_text(size = 15)) +
  labs(x = "Time", y = "Relative body temperature (°C)") +
  
  # Custom x-axis breaks and labels
  scale_x_continuous(
    breaks = c(0.0, 2.5, 5.0, 7.5, 10.0), 
    labels = c("19:00", "21:30", "00:00", "02:30", "05:00") 
  ) +
  coord_cartesian(ylim = c(-0.5, 3), expand = TRUE)


print(figure_2B)

